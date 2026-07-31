import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/iap_ids.dart';
import '../services/google_play_payment_service.dart';
import '../services/api_service.dart';

/// Purchase state per product.
enum PurchaseState { idle, loading, purchased, error }

/// Payment state — single source of truth for IAP in the app.
class PaymentProvider extends ChangeNotifier {
  late final GooglePlayPaymentService _paymentService;

  bool _ready = false;
  bool _initializing = true;
  String? _error;
  bool _purchaseInProgress = false;
  late final Future<void> _initialization;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Map of product ID → ProductDetails from Google Play.
  Map<String, ProductDetails> _products = {};

  /// Map of package ID → purchase state (for UI binding).
  Map<String, PurchaseState> _purchaseStates = {};

  bool get ready => _ready;
  bool get initializing => _initializing;
  String? get error => _error;
  bool get purchaseInProgress => _purchaseInProgress;
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);
  Map<String, PurchaseState> get purchaseStates =>
      Map.unmodifiable(_purchaseStates);
  GooglePlayPaymentService get paymentService => _paymentService;

  PaymentProvider(ApiService api) {
    _paymentService = GooglePlayPaymentService(api);
    _initialization = _init();
  }

  Future<void> _init() async {
    try {
      _ready = await _paymentService.init();
      if (_ready) {
        _listenToPurchases();
        await loadProducts();
      } else {
        _error = _paymentService.lastError;
      }
    } catch (e) {
      debugPrint('[IAP] Payment initialization error: $e');
      _ready = false;
      _error = 'Không thể khởi tạo Google Play Billing.';
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  void _listenToPurchases() {
    _purchaseSubscription = _paymentService.purchaseStream?.listen((purchases) {
      for (final purchase in purchases) {
        _handlePurchase(purchase);
      }
    });
  }

  Future<void> loadProducts() async {
    final ids = IapIds.creditProducts.values.toList();
    final details = await _paymentService.queryProducts(ids);

    _products = {};
    for (final d in details) {
      _products[d.id] = d;
    }

    _purchaseStates = {};
    for (final pid in ids) {
      _purchaseStates[pid] = PurchaseState.idle;
    }

    if (_products.isEmpty) {
      _error = _paymentService.lastError ??
          'Chưa có sản phẩm Google Play nào khả dụng.';
    }
    notifyListeners();
  }

  /// Start purchase for a credit package.
  Future<bool> buyCredits(String packageId) async {
    // PaymentProvider is created lazily. Always wait for Billing and product
    // discovery before looking up the selected SKU.
    await _initialization;

    if (!_ready) {
      _error =
          _paymentService.lastError ?? 'Google Play Billing chưa sẵn sàng.';
      notifyListeners();
      return false;
    }

    final sku = IapIds.productId(packageId, isDev: false);
    final product = _products[sku];
    if (product == null) {
      _error = _paymentService.lastError ??
          'Không tìm thấy sản phẩm $sku trên Google Play.';
      notifyListeners();
      return false;
    }

    _purchaseState(sku, PurchaseState.loading);
    _purchaseInProgress = true;
    _error = null;
    notifyListeners();

    final started = await _paymentService.purchase(product);
    if (!started) {
      _purchaseState(sku, PurchaseState.idle);
      _purchaseInProgress = false;
      _error = _paymentService.lastError ??
          'Google Play không thể mở giao diện thanh toán.';
      notifyListeners();
    }
    return started;
  }

  void _handlePurchase(PurchaseDetails purchase) {
    final sku = purchase.productID;
    final packageId = _skuToPackageId(sku);

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      _verifyAndConsume(purchase, packageId);
    } else if (purchase.status == PurchaseStatus.error) {
      _purchaseState(sku, PurchaseState.error);
      _error = purchase.error?.message ?? 'Purchase failed';
      _purchaseInProgress = false;
      notifyListeners();
    } else if (purchase.status == PurchaseStatus.canceled) {
      _purchaseState(sku, PurchaseState.idle);
      _purchaseInProgress = false;
      notifyListeners();
    }
  }

  Future<void> _verifyAndConsume(
      PurchaseDetails purchase, String packageId) async {
    final sku = purchase.productID;

    // 1. Verify receipt on backend
    final verified = await _paymentService.verifyReceipt(purchase);

    if (verified) {
      // 2. Consume (consumable product)
      await _paymentService.consume(purchase);
      _purchaseState(sku, PurchaseState.purchased);
      _error = null;
    } else {
      _purchaseState(sku, PurchaseState.error);
      _error = 'Receipt verification failed';
    }

    _purchaseInProgress = false;
    notifyListeners();
  }

  void _purchaseState(String sku, PurchaseState state) {
    // Map both sku and packageId
    _purchaseStates[sku] = state;
    final pkgId = _skuToPackageId(sku);
    _purchaseStates[pkgId] = state;
  }

  String _skuToPackageId(String sku) {
    // Reverse lookup: sku 'credit_10' → 'pkg_10'
    final reversed = IapIds.creditProducts.entries
        .where((e) => e.value == sku || '$e.value.dev' == sku)
        .toList();
    if (reversed.isEmpty) return sku;
    // Prefer non-dev
    return reversed
        .firstWhere(
          (e) => e.value == sku,
          orElse: () => reversed.first,
        )
        .key;
  }

  String? priceOf(String packageId) {
    final sku = IapIds.productId(packageId, isDev: false);
    final product = _products[sku];
    if (product == null) return null;
    return product.rawPrice.toString();
  }

  String? formattedPriceOf(String packageId) {
    final sku = IapIds.productId(packageId, isDev: false);
    final product = _products[sku];
    if (product == null) return null;
    return product.price;
  }

  Future<bool> restorePurchases() async {
    await _initialization;
    if (!_ready) {
      _error =
          _paymentService.lastError ?? 'Google Play Billing chưa sẵn sàng.';
      notifyListeners();
      return false;
    }

    final restored = await _paymentService.restorePurchases();
    if (!restored) {
      _error = _paymentService.lastError ??
          'Không thể khôi phục giao dịch Google Play.';
    } else {
      _error = null;
    }
    notifyListeners();
    return restored;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _paymentService.dispose();
    super.dispose();
  }
}
