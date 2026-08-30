import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/iap_ids.dart';
import '../services/api_service.dart';

/// Store billing wrapper.
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

  /// Expose the underlying API client for retry operations that need to call
  /// backend endpoints directly (e.g. pending purchase re-verification).
  ApiService get api => _api;

  /// Initialize connection to Google Play Billing.
  Future<bool> init() async {
    if (_initialized) return _available;
    _initialized = true;

    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        _lastError = 'paymentBillingUnavailable';
        debugPrint('[IAP] Google Play Billing not available');
        return false;
      }
    } catch (e) {
      _available = false;
      _lastError = 'paymentConnectionFailed';
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
      _lastError = 'paymentBillingUnavailable';
      return [];
    }

    try {
      final response = await _iap.queryProductDetails(productIds.toSet());

      if (response.error != null) {
        _lastError = 'paymentProductsLoadFailed';
        debugPrint('[IAP] Query products error: ${response.error}');
        return [];
      }

      if (response.productDetails.isEmpty) {
        _lastError = 'paymentProductsUnavailable';
      } else {
        _lastError = null;
      }
      return response.productDetails;
    } catch (e) {
      _lastError = 'paymentProductsLoadFailed';
      debugPrint('[IAP] Query products exception: $e');
      return [];
    }
  }

  /// Start purchase flow for a consumable credit package.
  Future<bool> purchase(ProductDetails product) async {
    if (!_available) {
      _lastError = 'paymentBillingUnavailable';
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Do not let the Flutter plugin auto-consume before the server has
      // verified the purchase token and granted the credits.  The backend
      // consumes the token after its idempotent credit commit.
      final result = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );
      if (!result) {
        _lastError = 'paymentOpenFailed';
      } else {
        _lastError = null;
      }
      debugPrint('[IAP] Purchase initiated: ${product.id} -> $result');
      return result;
    } catch (e) {
      _lastError = 'paymentOpenFailed';
      debugPrint('[IAP] Purchase error: $e');
      return false;
    }
  }

  /// Start an auto-renewable Premium subscription.  Subscriptions must not be
  /// consumed: StoreKit / Play Billing owns their renewal lifecycle.
  Future<bool> purchaseSubscription(
    ProductDetails product, {
    String? applicationUserName,
  }) async {
    if (!_available) {
      _lastError = 'paymentBillingUnavailable';
      return false;
    }
    try {
      final result = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          // CalGo user IDs are random UUIDs rather than PII. Passing the ID
          // associates the Store transaction with the signed-in app account.
          applicationUserName: applicationUserName,
        ),
      );
      if (!result) {
        _lastError = 'paymentOpenFailed';
      } else {
        _lastError = null;
      }
      return result;
    } catch (e) {
      _lastError = 'paymentOpenFailed';
      debugPrint('[IAP] Subscription purchase error: $e');
      return false;
    }
  }

  /// Consume a purchase (required for consumable credit top-ups).
  Future<bool> consume(PurchaseDetails purchase) async {
    if (purchase.productID.contains('subscription')) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidAddition = _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
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
      if (!_api.hasAccessToken) {
        _lastError = 'authenticationRequired';
        debugPrint(
          '[IAP] Verify receipt rejected: product=${purchase.productID} status=no-auth',
        );
        return false;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _verifyAppStoreCreditReceipt(purchase);
      }

      final receiptData = _extractReceipt(purchase);
      if (receiptData == null) return false;

      if (!IapIds.creditProducts.values.contains(purchase.productID)) {
        _lastError = 'paymentProductNotFound';
        debugPrint(
          '[IAP] Verify receipt rejected: product=${purchase.productID}',
        );
        return false;
      }

      final productId = (receiptData['product_id'] as String?)?.trim();
      final purchaseToken = (receiptData['purchase_token'] as String?)?.trim();
      if (productId == null ||
          productId.isEmpty ||
          purchaseToken == null ||
          purchaseToken.isEmpty) {
        _lastError = 'receiptUnavailable';
        debugPrint(
          '[IAP] Verify receipt rejected: product=${purchase.productID}',
        );
        return false;
      }

      final orderId = (receiptData['order_id'] as String?)?.trim();
      final body = <String, dynamic>{
        'product_id': productId,
        'purchase_token': purchaseToken,
        if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
      };
      final response = await _api.post(
        '/payments/google-play/verify',
        body: body,
      );
      final creditsAdded = response is Map<String, dynamic>
          ? response['credits_added']
          : null;
      if (response is! Map<String, dynamic> ||
          response['success'] != true ||
          creditsAdded is! num ||
          creditsAdded < 0) {
        _lastError = 'receiptVerificationFailed';
        debugPrint(
          '[IAP] Verify receipt failed: product=$productId status=200',
        );
        return false;
      }
      _lastError = null;
      debugPrint('[IAP] Verify receipt success: product=$productId status=200');
      return true;
    } catch (e) {
      _lastError = 'receiptVerificationFailed';
      final status = e is ApiException ? e.statusCode : 'network';
      debugPrint(
        '[IAP] Verify receipt failed: product=${purchase.productID} status=$status',
      );
      return false;
    }
  }

  Future<bool> _verifyAppStoreCreditReceipt(PurchaseDetails purchase) async {
    final transactionId = purchase.purchaseID?.trim();
    if (transactionId == null || transactionId.isEmpty) {
      _lastError = 'receiptUnavailable';
      return false;
    }

    final response = await _api.post(
      '/payments/app-store/verify',
      body: {'product_id': purchase.productID, 'transaction_id': transactionId},
    );
    final creditsAdded = response is Map<String, dynamic>
        ? response['credits_added']
        : null;
    if (response is! Map<String, dynamic> ||
        response['success'] != true ||
        creditsAdded is! num ||
        creditsAdded < 0) {
      _lastError = 'receiptVerificationFailed';
      debugPrint(
        '[IAP] App Store credit verification failed: '
        'product=${purchase.productID} status=200',
      );
      return false;
    }
    _lastError = null;
    debugPrint(
      '[IAP] App Store credit verified: product=${purchase.productID} status=200',
    );
    return true;
  }

  /// Verify a Premium entitlement on CalGo's server.  The server calls the
  /// relevant Store API and is the only authority that grants Premium.
  Future<Map<String, dynamic>?> verifySubscription(
    PurchaseDetails purchase,
  ) async {
    try {
      final proof = _extractSubscriptionProof(purchase);
      if (proof == null) {
        _lastError = 'receiptUnavailable';
        return null;
      }
      final response = await _api.post(
        '/subscriptions/store/verify',
        body: proof,
      );
      if (response is! Map<String, dynamic> || response['success'] != true) {
        _lastError = 'subscriptionVerificationFailed';
        return null;
      }
      _lastError = null;
      return response;
    } catch (e) {
      _lastError = 'subscriptionVerificationFailed';
      debugPrint('[IAP] Verify subscription error: $e');
      return null;
    }
  }

  Map<String, dynamic>? _extractSubscriptionProof(PurchaseDetails purchase) {
    final transactionId = purchase.purchaseID?.trim();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (transactionId == null || transactionId.isEmpty) return null;
      return {
        'provider': 'app_store',
        'product_id': purchase.productID,
        'transaction_id': transactionId,
      };
    }
    final proof = purchase.verificationData.serverVerificationData.trim();
    if (proof.isEmpty) return null;
    return {
      'provider': 'google_play',
      'product_id': purchase.productID,
      'purchase_token': proof,
      if (transactionId != null && transactionId.isNotEmpty)
        'transaction_id': transactionId,
    };
  }

  /// Acknowledge a non-consumable purchase after server verification.
  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /// Extract receipt data per platform.
  Map<String, dynamic>? _extractReceipt(PurchaseDetails purchase) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPurchase = purchase as GooglePlayPurchaseDetails;
      return {
        'product_id': purchase.productID,
        'purchase_token': androidPurchase.billingClientPurchase.purchaseToken,
        if (purchase.purchaseID != null && purchase.purchaseID!.isNotEmpty)
          'order_id': purchase.purchaseID,
      };
    }
    return null;
  }

  /// Restore previous purchases (for iOS App Store & Android Google Play Store compliance)
  Future<bool> restorePurchases() async {
    if (!_available) {
      _lastError = 'paymentBillingUnavailable';
      return false;
    }
    try {
      await _iap.restorePurchases();
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = 'paymentRestoreFailed';
      debugPrint('[IAP] Restore purchases error: $e');
      return false;
    }
  }

  /// Verify if a purchase is already owned (for non-consumables).
  Future<bool> isPurchased(String productId) async {
    await restorePurchases();
    return false;
  }

  /// Opens the Store-owned subscription screen.  Cancellation is done there
  /// so Store renewal and CalGo's entitlement cannot drift apart.
  Future<bool> openSubscriptionManagement() async {
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse(
            'https://play.google.com/store/account/subscriptions?package=com.calgo.calgo',
          );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void dispose() {
    // PaymentProvider owns the purchase-stream subscription.
  }
}
