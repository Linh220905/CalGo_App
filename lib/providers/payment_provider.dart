import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_build_config.dart';
import '../config/iap_ids.dart';
import '../services/google_play_payment_service.dart';
import '../services/api_service.dart';
import '../utils/payment_platform.dart';

/// Purchase state per product.
enum PurchaseState {
  idle,
  loading,
  pending,
  verifying,
  purchased,
  canceled,
  error,
}

enum PremiumPlan { weekly, monthly, annual }

/// One concrete Store offer. Google Play may return several entries with the
/// same product ID (base plan, free trial, win-back, etc.), so a subscription
/// catalog must never be flattened into a product-ID-only map.
class PremiumOffer {
  final PremiumPlan plan;
  final ProductDetails product;
  final String? basePlanId;
  final String? offerId;
  final List<String> offerTags;
  final bool hasFreeTrial;
  final int trialDays;
  final String recurringPrice;

  const PremiumOffer({
    required this.plan,
    required this.product,
    required this.basePlanId,
    required this.offerId,
    required this.offerTags,
    required this.hasFreeTrial,
    required this.trialDays,
    required this.recurringPrice,
  });

  /// Approximate weekly cost derived from the store's raw price micros.
  /// Returns null when the raw price is unavailable (loading or not discovered).
  String? get weeklyPrice {
    final rawMicros = product.rawPrice;
    if (rawMicros <= 0) return null;
    final currencySymbol = product.currencyCode;
    double weeklyAmount;
    switch (plan) {
      case PremiumPlan.weekly:
        weeklyAmount = rawMicros;
        break;
      case PremiumPlan.monthly:
        weeklyAmount = rawMicros / 4.33;
        break;
      case PremiumPlan.annual:
        weeklyAmount = rawMicros / 52;
        break;
    }
    // Format: if >= 1000 show as e.g. "23.1k" else as integer
    if (weeklyAmount >= 1000) {
      final k = weeklyAmount / 1000;
      final formatted = k >= 10 ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
      return '~${formatted}k\u00a0$currencySymbol';
    }
    return '~${weeklyAmount.round()}\u00a0$currencySymbol';
  }

  factory PremiumOffer.fromProduct(PremiumPlan plan, ProductDetails product) {
    if (product is AppStoreProductDetails) {
      final introductory = product.skProduct.introductoryPrice;
      final hasFreeTrial =
          introductory != null &&
          introductory.paymentMode == SKProductDiscountPaymentMode.freeTrail;
      final trialDays = hasFreeTrial
          ? _storeKitPeriodDays(introductory.subscriptionPeriod) *
                introductory.numberOfPeriods
          : 0;
      return PremiumOffer(
        plan: plan,
        product: product,
        basePlanId: null,
        offerId: introductory?.identifier,
        offerTags: const [],
        hasFreeTrial: hasFreeTrial && trialDays > 0,
        trialDays: trialDays,
        recurringPrice: product.price,
      );
    }

    if (product is! GooglePlayProductDetails ||
        product.subscriptionIndex == null) {
      return PremiumOffer(
        plan: plan,
        product: product,
        basePlanId: null,
        offerId: null,
        offerTags: const [],
        hasFreeTrial: false,
        trialDays: 0,
        recurringPrice: product.price,
      );
    }

    final offers = product.productDetails.subscriptionOfferDetails;
    final index = product.subscriptionIndex!;
    if (offers == null || index < 0 || index >= offers.length) {
      return PremiumOffer(
        plan: plan,
        product: product,
        basePlanId: null,
        offerId: null,
        offerTags: const [],
        hasFreeTrial: false,
        trialDays: 0,
        recurringPrice: product.price,
      );
    }

    final details = offers[index];
    final freePhases = details.pricingPhases
        .where((phase) => phase.priceAmountMicros == 0)
        .toList();
    final paidPhases = details.pricingPhases
        .where((phase) => phase.priceAmountMicros > 0)
        .toList();
    final recurring = paidPhases.isNotEmpty
        ? paidPhases.last.formattedPrice
        : product.price;
    final trialDays = freePhases.fold<int>(
      0,
      (days, phase) =>
          days + _periodDays(phase.billingPeriod) * phase.billingCycleCount,
    );

    return PremiumOffer(
      plan: plan,
      product: product,
      basePlanId: details.basePlanId,
      offerId: details.offerId,
      offerTags: List.unmodifiable(details.offerTags),
      hasFreeTrial: freePhases.isNotEmpty,
      trialDays: trialDays,
      recurringPrice: recurring,
    );
  }

  static int _periodDays(String period) {
    final match = RegExp(r'^P(\d+)([DWMY])$').firstMatch(period);
    if (match == null) return 0;
    final value = int.tryParse(match.group(1) ?? '') ?? 0;
    return switch (match.group(2)) {
      'D' => value,
      'W' => value * 7,
      'M' => value * 30,
      'Y' => value * 365,
      _ => 0,
    };
  }

  static int _storeKitPeriodDays(SKProductSubscriptionPeriodWrapper period) {
    return switch (period.unit) {
      SKSubscriptionPeriodUnit.day => period.numberOfUnits,
      SKSubscriptionPeriodUnit.week => period.numberOfUnits * 7,
      // This is intentionally an approximation for UI copy only. The
      // server's signed Apple transaction calculates the exact trial_end.
      SKSubscriptionPeriodUnit.month => period.numberOfUnits * 30,
      SKSubscriptionPeriodUnit.year => period.numberOfUnits * 365,
    };
  }
}

/// Payment state — single source of truth for IAP in the app.
class PaymentProvider extends ChangeNotifier {
  late final GooglePlayPaymentService _paymentService;

  bool _ready = false;
  bool _initializing = true;
  String? _error;
  bool _purchaseInProgress = false;
  late final Future<void> _initialization;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Future<void> Function()? _onCreditsVerified;

  /// Map of product ID → ProductDetails from Google Play.
  Map<String, ProductDetails> _products = {};

  /// Every eligible Premium offer returned by the Store, grouped by plan.
  Map<PremiumPlan, List<PremiumOffer>> _premiumOffers = {};
  PremiumOffer? _activePremiumOffer;
  Map<String, dynamic>? _lastSubscriptionVerification;

  /// Map of package ID → purchase state (for UI binding).
  Map<String, PurchaseState> _purchaseStates = {};

  bool get ready => _ready;
  bool get initializing => _initializing;
  String? get error => _error;
  bool get purchaseInProgress => _purchaseInProgress;
  bool get billingEnabled => AppBuildConfig.googlePlayBillingEnabled;
  bool get premiumFreeForTesting => AppBuildConfig.premiumFreeForTesting;
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);
  Map<PremiumPlan, List<PremiumOffer>> get premiumOffers => Map.unmodifiable(
    _premiumOffers.map(
      (plan, offers) => MapEntry(plan, List.unmodifiable(offers)),
    ),
  );
  PremiumOffer? get activePremiumOffer => _activePremiumOffer;
  Map<String, dynamic>? get lastSubscriptionVerification =>
      _lastSubscriptionVerification == null
      ? null
      : Map.unmodifiable(_lastSubscriptionVerification!);
  Map<String, PurchaseState> get purchaseStates =>
      Map.unmodifiable(_purchaseStates);
  GooglePlayPaymentService get paymentService => _paymentService;

  static String productIdForPremiumPlan(PremiumPlan plan) => switch (plan) {
    PremiumPlan.weekly => IapIds.premiumWeekly,
    PremiumPlan.monthly => IapIds.premiumMonthly,
    PremiumPlan.annual => IapIds.premiumAnnual,
  };

  ProductDetails? premiumProduct(PremiumPlan plan) =>
      premiumOffer(plan, preferFreeTrial: false)?.product;

  PremiumOffer? premiumOffer(
    PremiumPlan plan, {
    required bool preferFreeTrial,
  }) {
    final offers = _premiumOffers[plan] ?? const <PremiumOffer>[];
    if (offers.isEmpty) return null;
    // Weekly Premium never has a free-trial offer. Keep this guard in the
    // client even if a stale/misconfigured Play Console offer is returned.
    if (plan == PremiumPlan.weekly) {
      for (final offer in offers) {
        if (!offer.hasFreeTrial) return offer;
      }
      return null;
    }
    if (preferFreeTrial) {
      for (final offer in offers) {
        if (offer.hasFreeTrial) return offer;
      }
      return null;
    }
    for (final offer in offers) {
      if (!offer.hasFreeTrial && offer.offerId == null) return offer;
    }
    for (final offer in offers) {
      if (!offer.hasFreeTrial) return offer;
    }
    return offers.first;
  }

  bool hasTrialOffer(PremiumPlan plan) =>
      (_premiumOffers[plan] ?? const <PremiumOffer>[]).any(
        (offer) => offer.hasFreeTrial,
      );

  PremiumOffer? premiumOfferWithTag(PremiumPlan plan, String tag) {
    final normalized = tag.trim().toLowerCase();
    for (final offer in _premiumOffers[plan] ?? const <PremiumOffer>[]) {
      if (offer.offerId?.toLowerCase() == normalized ||
          offer.offerTags.any((value) => value.toLowerCase() == normalized)) {
        return offer;
      }
    }
    return null;
  }

  PaymentProvider(ApiService api) {
    _paymentService = GooglePlayPaymentService(api);
    _initialization = billingEnabled ? _init() : _disableForTesting();
  }

  /// Called after the server has committed a credit top-up so the signed-in
  /// user model (and every credits badge) reflects the new balance.
  void setCreditsVerifiedCallback(Future<void> Function() callback) {
    _onCreditsVerified = callback;
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

    final ids = [...IapIds.creditProducts.values, ...IapIds.premiumProducts];
    final details = await _paymentService.queryProducts(ids);

    _products = {};
    _premiumOffers = {
      for (final plan in PremiumPlan.values) plan: <PremiumOffer>[],
    };
    for (final d in details) {
      final plan = _premiumPlanForProductId(d.id);
      if (plan == null) {
        _products[d.id] = d;
        continue;
      }
      final offer = PremiumOffer.fromProduct(plan, d);
      _premiumOffers[plan]!.add(offer);
      // Preserve the old product lookup for callers outside Premium. Prefer a
      // regular base plan over an introductory offer when both are returned.
      final existing = _products[d.id];
      if (existing == null || (!offer.hasFreeTrial && offer.offerId == null)) {
        _products[d.id] = d;
      }
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
  Future<bool> buyPremium(
    PremiumPlan plan, {
    required bool preferFreeTrial,
    String? applicationUserName,
    PremiumOffer? selectedOffer,
  }) async {
    await _initialization;
    if (!billingEnabled) return false;
    if (!_ready) {
      _error = _paymentService.lastError ?? 'paymentNotReady';
      notifyListeners();
      return false;
    }

    final sku = productIdForPremiumPlan(plan);
    final offer = selectedOffer?.plan == plan
        ? selectedOffer
        : premiumOffer(plan, preferFreeTrial: preferFreeTrial);
    if (offer == null) {
      _error = preferFreeTrial
          ? 'paymentTrialUnavailable'
          : (_paymentService.lastError ?? 'paymentPackageUnavailable');
      notifyListeners();
      return false;
    }

    _purchaseState(sku, PurchaseState.loading);
    _purchaseInProgress = true;
    _activePremiumOffer = offer;
    _lastSubscriptionVerification = null;
    _error = null;
    notifyListeners();

    final started = await _paymentService.purchaseSubscription(
      offer.product,
      applicationUserName: applicationUserName,
    );
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
    } else if (purchase.status == PurchaseStatus.pending) {
      _purchaseState(sku, PurchaseState.pending);
      _error = 'purchasePending';
      _purchaseInProgress = false;
      notifyListeners();
    } else if (purchase.status == PurchaseStatus.canceled) {
      _purchaseState(sku, PurchaseState.canceled);
      _error = null;
      _purchaseInProgress = false;
      notifyListeners();
    }
  }

  Future<void> _verifyAndConsume(
    PurchaseDetails purchase,
    String packageId,
  ) async {
    final sku = purchase.productID;

    // 1. Verify receipt on backend
    final verified = await _paymentService.verifyReceipt(purchase);

    if (verified) {
      await _clearPendingPurchase();
      // The backend verifies, commits credits, and consumes the token. Calling
      // completePurchase is still safe and clears any pending client-side
      // transaction state; Android returns OK for an already acknowledged
      // purchase.
      try {
        await _paymentService.complete(purchase);
      } catch (error) {
        // Server-side credit grant is authoritative; Play cleanup can be
        // retried from the purchase stream/restore path.
        debugPrint('[IAP] Credit completePurchase cleanup failed: $error');
      }
      try {
        await _onCreditsVerified?.call();
      } catch (error) {
        // The purchase is already committed server-side. A refresh failure
        // must not turn a successful top-up into a client-side error.
        debugPrint('[IAP] Credit balance refresh failed: $error');
      }
      _purchaseState(sku, PurchaseState.purchased);
      _error = null;
    } else {
      // Persist for retry on next cold start so a transient auth failure
      // does not permanently lose a paid purchase.
      await _savePendingPurchase(purchase);
      _purchaseState(sku, PurchaseState.error);
      _error = _paymentService.lastError ?? 'receiptVerificationFailed';
    }

    _purchaseInProgress = false;
    notifyListeners();
  }

  Future<void> _verifySubscription(PurchaseDetails purchase) async {
    final sku = purchase.productID;
    final initiatedInThisSession = _purchaseInProgress;
    _purchaseState(sku, PurchaseState.verifying);
    _purchaseInProgress = true;
    notifyListeners();
    final verification = await _paymentService.verifySubscription(purchase);
    if (verification != null) {
      // Keep purchase-vs-restore provenance for analytics. Restoring an
      // existing entitlement must not be counted as a new purchase.
      _lastSubscriptionVerification = {
        ...verification,
        'product_id': purchase.productID,
        'is_restored':
            purchase.status == PurchaseStatus.restored ||
            !initiatedInThisSession,
      };
      _purchaseState(sku, PurchaseState.purchased);
      _error = null;
      _purchaseInProgress = false;
      await _clearPendingPurchase();
      // The server has already verified and granted the entitlement. Clearing
      // the local Play transaction is cleanup and must not block the success
      // UI if Play reports an already-acknowledged transaction here.
      notifyListeners();
      try {
        await _paymentService.complete(purchase);
      } catch (error) {
        debugPrint('[IAP] completePurchase cleanup failed: $error');
      }
      return;
    } else {
      // Persist for retry on next cold start so a transient auth failure
      // does not permanently lose a paid purchase.
      await _savePendingPurchase(purchase);
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
        .firstWhere((e) => e.value == sku, orElse: () => reversed.first)
        .key;
  }

  PremiumPlan? _premiumPlanForProductId(String productId) {
    for (final plan in PremiumPlan.values) {
      if (productIdForPremiumPlan(plan) == productId) return plan;
    }
    return null;
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

  // ── Pending purchase persistence ────────────────────────────────────────
  static const _pendingPurchaseKey = 'pending_purchase_verification';

  Future<void> _savePendingPurchase(PurchaseDetails purchase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'product_id': purchase.productID,
        'purchase_id': purchase.purchaseID,
        'verification_data': purchase.verificationData.serverVerificationData,
        'is_subscription': IapIds.isPremiumProduct(purchase.productID),
        'saved_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_pendingPurchaseKey, jsonEncode(data));
      debugPrint(
        '[IAP] Saved pending purchase for retry: ${purchase.productID}',
      );
    } catch (e) {
      debugPrint('[IAP] Failed to save pending purchase: $e');
    }
  }

  Future<void> _clearPendingPurchase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingPurchaseKey);
    } catch (_) {}
  }

  /// Called after a successful auth restore. Retries any purchase verification
  /// that failed on a previous session due to an expired token.
  Future<void> retryPendingPurchaseVerification() async {
    await _initialization;
    if (!billingEnabled || !_ready) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingPurchaseKey);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final productId = data['product_id'] as String?;
      final purchaseToken = data['verification_data'] as String?;
      final transactionId = data['purchase_id'] as String?;
      final isSub = data['is_subscription'] as bool? ?? false;
      if (productId == null ||
          (isAppleBillingPlatform
              ? transactionId == null
              : purchaseToken == null)) {
        await _clearPendingPurchase();
        return;
      }
      debugPrint('[IAP] Retrying pending verification: $productId');

      if (isSub) {
        final result = await _paymentService.api.post(
          '/subscriptions/store/verify',
          body: {
            'provider': isAppleBillingPlatform ? 'app_store' : 'google_play',
            'product_id': productId,
            if (isAppleBillingPlatform)
              'transaction_id': transactionId
            else
              'purchase_token': purchaseToken,
          },
        );
        if (result is Map<String, dynamic> && result['success'] == true) {
          _lastSubscriptionVerification = result;
          _purchaseState(productId, PurchaseState.purchased);
          await _clearPendingPurchase();
          debugPrint('[IAP] Pending subscription verified successfully');
          notifyListeners();
        }
      } else {
        final endpoint = isAppleBillingPlatform
            ? '/payments/app-store/verify'
            : '/payments/google-play/verify';
        final result = await _paymentService.api.post(
          endpoint,
          body: {
            'product_id': productId,
            if (isAppleBillingPlatform)
              'transaction_id': transactionId
            else
              'purchase_token': purchaseToken,
          },
        );
        if (result is Map<String, dynamic> && result['success'] == true) {
          await _clearPendingPurchase();
          try {
            await _onCreditsVerified?.call();
          } catch (_) {}
          _purchaseState(productId, PurchaseState.purchased);
          debugPrint('[IAP] Pending credit purchase verified successfully');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[IAP] Pending purchase retry failed: $e');
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _paymentService.dispose();
    super.dispose();
  }
}
