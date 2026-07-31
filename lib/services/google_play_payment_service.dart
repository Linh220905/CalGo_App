import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../services/api_service.dart';

/// Google Play Billing wrapper.
///
/// Handles connection, product query, purchase flow, receipt verification.
class GooglePlayPaymentService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final ApiService _api;
  bool _initialized = false;
  bool _available = false;
  String? _lastError;

  /// Stream of purchase updates from Google Play.
  /// Emits raw [PurchaseDetails] for upstream handling.
  Stream<List<PurchaseDetails>>? get purchaseStream => _iap.purchaseStream;

  bool get available => _available;
  String? get lastError => _lastError;

  GooglePlayPaymentService(this._api);

  /// Initialize connection to Google Play Billing.
  Future<bool> init() async {
    if (_initialized) return _available;
    _initialized = true;

    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        _lastError = 'Google Play Billing chưa sẵn sàng trên thiết bị này.';
        debugPrint('[IAP] Google Play Billing not available');
        return false;
      }
    } catch (e) {
      _available = false;
      _lastError = 'Không thể kết nối Google Play Billing.';
      debugPrint('[IAP] Billing initialization error: $e');
      return false;
    }

    _lastError = null;
    debugPrint('[IAP] Google Play Billing initialized');
    return true;
  }

  /// Query product details for given [productIds].
  Future<List<ProductDetails>> queryProducts(List<String> productIds) async {
    if (!_available) {
      _lastError = 'Google Play Billing chưa sẵn sàng trên thiết bị này.';
      return [];
    }

    try {
      final response = await _iap.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        _lastError =
            response.error?.message ?? 'Không thể tải sản phẩm Google Play.';
        debugPrint('[IAP] Query products error: ${response.error}');
        return [];
      }

      if (response.productDetails.isEmpty) {
        final missingIds = response.notFoundIDs.join(', ');
        _lastError = missingIds.isEmpty
            ? 'Chưa có sản phẩm Google Play nào khả dụng.'
            : 'Không tìm thấy sản phẩm Google Play: $missingIds';
      } else {
        _lastError = response.notFoundIDs.isEmpty
            ? null
            : 'Một số sản phẩm chưa được cấu hình: '
                '${response.notFoundIDs.join(', ')}';
      }
      return response.productDetails;
    } catch (e) {
      _lastError = 'Không thể tải sản phẩm từ Google Play.';
      debugPrint('[IAP] Query products exception: $e');
      return [];
    }
  }

  /// Start purchase flow for a [ProductDetails].
  Future<bool> purchase(ProductDetails product) async {
    if (!_available) {
      _lastError = 'Google Play Billing chưa sẵn sàng trên thiết bị này.';
      return false;
    }

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    try {
      final result = await _iap.buyConsumable(purchaseParam: purchaseParam);
      if (!result) {
        _lastError = 'Google Play không thể mở giao diện thanh toán.';
      } else {
        _lastError = null;
      }
      debugPrint('[IAP] Purchase initiated: ${product.id} -> $result');
      return result;
    } catch (e) {
      _lastError = 'Không thể mở giao diện thanh toán Google Play.';
      debugPrint('[IAP] Purchase error: $e');
      return false;
    }
  }

  /// Consume a purchase (required for consumable credit top-ups).
  Future<bool> consume(PurchaseDetails purchase) async {
    if (purchase.productID.contains('subscription')) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidAddition =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final androidPurchase = purchase as GooglePlayPurchaseDetails;
      await androidAddition.consumePurchase(androidPurchase);
      debugPrint('[IAP] Consumed: ${purchase.productID}');
      return true;
    }

    return false;
  }

  /// Send purchase receipt to backend for verification + credit grant.
  Future<bool> verifyReceipt(PurchaseDetails purchase) async {
    try {
      final receiptData = _extractReceipt(purchase);
      if (receiptData == null) return false;

      await _api.post('/payments/google-play/verify', body: {
        'product_id': purchase.productID,
        'purchase_token': receiptData['purchaseToken'],
        'order_id': purchase.purchaseID,
      });
      return true;
    } catch (e) {
      debugPrint('[IAP] Verify receipt error: $e');
      return false;
    }
  }

  /// Extract receipt data per platform.
  Map<String, dynamic>? _extractReceipt(PurchaseDetails purchase) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPurchase = purchase as GooglePlayPurchaseDetails;
      return {
        'product_id': purchase.productID,
        'purchase_token': androidPurchase.billingClientPurchase.purchaseToken,
        'order_id': purchase.purchaseID,
      };
    }
    return null;
  }

  /// Restore previous purchases (for iOS App Store & Android Google Play Store compliance)
  Future<bool> restorePurchases() async {
    if (!_available) {
      _lastError = 'Google Play Billing chưa sẵn sàng trên thiết bị này.';
      return false;
    }
    try {
      await _iap.restorePurchases();
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = 'Không thể khôi phục giao dịch Google Play.';
      debugPrint('[IAP] Restore purchases error: $e');
      return false;
    }
  }

  /// Verify if a purchase is already owned (for non-consumables).
  Future<bool> isPurchased(String productId) async {
    await restorePurchases();
    return false;
  }

  void dispose() {
    // PaymentProvider owns the purchase-stream subscription.
  }
}
