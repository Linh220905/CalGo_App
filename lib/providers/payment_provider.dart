import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/app_build_config.dart';
import '../config/iap_ids.dart';
import '../services/google_play_payment_service.dart';
import '../services/api_service.dart';

/// Purchase state per product.
enum PurchaseState { idle, loading, purchased, error }

enum PremiumPlan { weekly, monthly, annual }

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
  bool get billingEnabled => AppBuildConfig.googlePlayBillingEnabled;
  bool get premiumFreeForTesting => AppBuildConfig.premiumFreeForTesting;
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);
  Map<String, PurchaseState> get purchaseStates =>
      Map.unmodifiable(_purchaseStates);
  GooglePlayPaymentService get paymentService => _paymentService;

  static String productIdForPremiumPlan(PremiumPlan plan) => switch (plan) {
        PremiumPlan.weekly => IapIds.premiumWeekly,
        PremiumPlan.monthly => IapIds.premiumMonthly,
        PremiumPlan.annual => IapIds.premiumAnnual,
      };

  ProductDetails? premiumProduct(PremiumPlan plan) =>
      _products[productIdForPremiumPlan(plan)];

  PaymentProvider(ApiService api) {
    _paymentService = GooglePlayPaymentService(api);
    _initialization = billingEnabled ? _init() : _disableForTesting();
  }

  Future<void> _disableForTesting() async {
    // Keep the provider and all production purchase code present, but do not
    // connect to Google Play Billing in the testing flavor.
    _ready = false;
    _initializing = false;
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
      _error = 'paymentInitializationFailed';
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
    if (!billingEnabled) return;

    final ids = [
      ...IapIds.creditProducts.values,
      ...IapIds.premiumProducts,
    ];
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
      _error = _paymentService.lastError ?? 'paymentProductsUnavailable';
    }
    notifyListeners();
  }

  /// Begins an auto-renewable Premium purchase. Completion is delivered by
  /// the Store purchase stream and verified server-side before UI success.
  Future<bool> buyPremium(PremiumPlan plan) async {
    await _initialization;
    if (!billingEnabled) return false;
    if (!_ready) {
      _error = _paymentService.lastError ?? 'paymentNotReady';
      notifyListeners();
      return false;
    }

    final sku = productIdForPremiumPlan(plan);
    final product = _products[sku];
    if (product == null) {
      _error = _paymentService.lastError ?? 'paymentPackageUnavailable';
      notifyListeners();
      return false;
    }

    _purchaseState(sku, PurchaseState.loading);
    _purchaseInProgress = true;
    _error = null;
    notifyListeners();

    final started = await _paymentService.purchaseSubscription(product);
    if (!started) {
      _purchaseState(sku, PurchaseState.idle);
      _purchaseInProgress = false;
      _error = _paymentService.lastError ?? 'paymentOpenFailed';
      notifyListeners();
    }
    return started;
  }

  /// Start purchase for a credit package.
  Future<bool> buyCredits(String packageId, {required int creditAmount}) async {
    // PaymentProvider is created lazily. Always wait for Billing and product
    // discovery before looking up the selected SKU.
    await _initialization;

    if (!billingEnabled) return false;

    if (!_ready) {
      _error = _paymentService.lastError ?? 'paymentBillingUnavailable';
      notifyListeners();
      return false;
    }

    // The API package id is a UUID; Google Play uses the stable SKU based on
    // the credit amount instead of assuming a fake pkg_10-style id.
    final sku = IapIds.productIdForCreditAmount(creditAmount, isDev: false);
    final product = _products[sku];
    if (product == null) {
      _error = _paymentService.lastError ?? 'paymentProductNotFound';
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
      _error = _paymentService.lastError ?? 'paymentOpenFailed';
      notifyListeners();
    }
    return started;
  }

  void _handlePurchase(PurchaseDetails purchase) {
    final sku = purchase.productID;
    final packageId = _skuToPackageId(sku);

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      if (IapIds.isPremiumProduct(sku)) {
        _verifySubscription(purchase);
      } else {
        _verifyAndConsume(purchase, packageId);
      }
    } else if (purchase.status == PurchaseStatus.error) {
      _purchaseState(sku, PurchaseState.error);
      _error = 'purchaseFailed';
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
      // The backend verifies, commits credits, and consumes the token. Calling
      // completePurchase is still safe and clears any pending client-side
      // transaction state; Android returns OK for an already acknowledged
      // purchase.
      await _paymentService.complete(purchase);
      _purchaseState(sku, PurchaseState.purchased);
      _error = null;
    } else {
      _purchaseState(sku, PurchaseState.error);
      _error = 'receiptVerificationFailed';
    }

    _purchaseInProgress = false;
    notifyListeners();
  }

  Future<void> _verifySubscription(PurchaseDetails purchase) async {
    final sku = purchase.productID;
    final verified = await _paymentService.verifySubscription(purchase);
    if (verified) {
      await _paymentService.complete(purchase);
      _purchaseState(sku, PurchaseState.purchased);
      _error = null;
    } else {
      _purchaseState(sku, PurchaseState.error);
      _error = _paymentService.lastError ?? 'subscriptionVerificationFailed';
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
        .where((e) => e.value == sku || '${e.value}.dev' == sku)
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

  String? formattedPriceForCreditAmount(int creditAmount) {
    final sku = IapIds.productIdForCreditAmount(creditAmount, isDev: false);
    return _products[sku]?.price;
  }

  Future<bool> restorePurchases() async {
    await _initialization;
    if (!billingEnabled) return false;
    if (!_ready) {
      _error = _paymentService.lastError ?? 'paymentBillingUnavailable';
      notifyListeners();
      return false;
    }

    final restored = await _paymentService.restorePurchases();
    if (!restored) {
      _error = _paymentService.lastError ?? 'paymentRestoreFailed';
    } else {
      _error = null;
    }
    notifyListeners();
    return restored;
  }

  Future<bool> openSubscriptionManagement() {
    if (!billingEnabled) return Future.value(false);
    return _paymentService.openSubscriptionManagement();
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
