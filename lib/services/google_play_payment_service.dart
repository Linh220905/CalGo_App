import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:url_launcher/url_launcher.dart';
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

    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

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
  Future<bool> purchaseSubscription(ProductDetails product) async {
    if (!_available) {
      _lastError = 'paymentBillingUnavailable';
      return false;
    }
    try {
      final result = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
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

  /// Verify a Premium entitlement on CalGo's server.  The server calls the
  /// relevant Store API and is the only authority that grants Premium.
  Future<bool> verifySubscription(PurchaseDetails purchase) async {
    try {
      final proof = _extractSubscriptionProof(purchase);
      if (proof == null) {
        _lastError = 'receiptUnavailable';
        return false;
      }
      await _api.post('/subscriptions/store/verify', body: proof);
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = 'subscriptionVerificationFailed';
      debugPrint('[IAP] Verify subscription error: $e');
      return false;
    }
  }

  Map<String, dynamic>? _extractSubscriptionProof(PurchaseDetails purchase) {
    final proof = purchase.verificationData.serverVerificationData;
    if (proof.isEmpty) return null;
    return {
      'provider': defaultTargetPlatform == TargetPlatform.iOS
          ? 'app_store'
          : 'google_play',
      'product_id': purchase.productID,
      'purchase_token': proof,
      'transaction_id': purchase.purchaseID,
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
