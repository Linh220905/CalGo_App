import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'api_service.dart';

class RevenueCatService {
  RevenueCatService._();

  static const String _envApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'test_caqXpahYGVvFqCtaYqdb0bZQZKt',
  );
  static const String _envIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: 'appl_ewZBuGVynrAWHYczmwxNOfpXrhF',
  );
  static const String _envAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: 'goog_xceHZqyMatSbyscQyBdoDYmIoZL',
  );

  static const String entitlementId = 'calgo_pro';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initialize RevenueCat SDK with the signed-in User ID.
  static Future<void> init({String? appUserId}) async {
    if (kIsWeb) return;
    if (_initialized) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final apiKey = _getApiKey();
      if (apiKey.isEmpty) {
        debugPrint('[RevenueCat] No API key configured');
        return;
      }

      final configuration = PurchasesConfiguration(apiKey);
      if (appUserId != null && appUserId.isNotEmpty) {
        configuration.appUserID = appUserId;
      }

      await Purchases.configure(configuration);
      _initialized = true;
      debugPrint('[RevenueCat] Configured successfully for user: ${appUserId ?? "anonymous"}');
    } catch (e) {
      debugPrint('[RevenueCat] Initialization failed: $e');
    }
  }

  /// Selects the appropriate API key based on OS platform and env configuration.
  static String _getApiKey() {
    if (kIsWeb) return _envApiKey;
    if (Platform.isIOS && _envIosApiKey.isNotEmpty) {
      return _envIosApiKey;
    }
    if (Platform.isAndroid && _envAndroidApiKey.isNotEmpty) {
      return _envAndroidApiKey;
    }
    return _envApiKey;
  }

  /// Set user ID after login, merge anonymous purchases, and verify identity.
  /// If [apiService] is provided and user has active entitlements, triggers backend sync with server-side verification.
  static Future<LogInResult?> logIn(String userId, {ApiService? apiService}) async {
    if (kIsWeb) return null;
    if (!_initialized) {
      await init(appUserId: userId);
      return null;
    }
    try {
      final logInResult = await Purchases.logIn(userId);
      final currentAppUserId = await Purchases.appUserID;
      final activeEntitlements = logInResult.customerInfo.entitlements.active.keys.toList();
      debugPrint('[RC] Logged in user: $userId (appUserID: $currentAppUserId, created: ${logInResult.created}), active entitlements: $activeEntitlements');

      final isEntitled = logInResult.customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
      final hasActive = logInResult.customerInfo.entitlements.active.isNotEmpty;

      if ((isEntitled || hasActive) && apiService != null) {
        try {
          // Trigger backend to verify subscriber status directly with RevenueCat REST API
          await apiService.post('/subscriptions/revenuecat/sync');
          debugPrint('[RC] Successfully requested backend verification sync for user $userId');
        } catch (e) {
          debugPrint('[RC] Backend subscription sync error: $e');
        }
      }

      return logInResult;
    } catch (e) {
      debugPrint('[RC] Login error for $userId: $e');
      return null;
    }
  }

  /// Reset identity on logout.
  static Future<void> logOut() async {
    if (kIsWeb || !_initialized) return;
    try {
      final customerInfo = await Purchases.logOut();
      final currentAppUserId = await Purchases.appUserID;
      debugPrint('[RC] Logged out successfully. New anonymous ID: $currentAppUserId, active: ${customerInfo.entitlements.active.keys.toList()}');
    } catch (e) {
      debugPrint('[RC] Logout error: $e');
    }
  }

  /// Check if the user currently holds an active premium entitlement.
  static Future<bool> isPremium() async {
    if (kIsWeb || !_initialized) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('[RevenueCat] Check premium error: $e');
      return false;
    }
  }

  static Offerings? _cachedOfferings;
  static Offerings? get cachedOfferings => _cachedOfferings;

  /// Fetch current offerings (Weekly, Monthly, Annual packages).
  static Future<Offerings?> getOfferings() async {
    if (kIsWeb) return null;
    if (!_initialized) await init();
    try {
      final offerings = await Purchases.getOfferings();
      _cachedOfferings = offerings;
      return offerings;
    } catch (e) {
      debugPrint('[RevenueCat] Fetch offerings error: $e');
      return _cachedOfferings;
    }
  }

  /// Fetch standalone store products (e.g. consumable credit packages).
  static Future<List<StoreProduct>> getProducts(
    List<String> productIdentifiers, {
    ProductCategory productCategory = ProductCategory.nonSubscription,
  }) async {
    if (kIsWeb) return [];
    if (!_initialized) await init();
    try {
      final products = await Purchases.getProducts(
        productIdentifiers,
        productCategory: productCategory,
      );
      return products;
    } catch (e) {
      debugPrint('[RevenueCat] Get products error: $e');
      return [];
    }
  }

  /// Purchase a standalone store product (e.g. consumable credit package).
  static Future<CustomerInfo?> purchaseStoreProduct(StoreProduct product) async {
    if (kIsWeb) return null;
    if (!_initialized) await init();
    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.storeProduct(product),
      );
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RevenueCat] User cancelled purchase');
      } else {
        debugPrint('[RevenueCat] Purchase exception: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('[RevenueCat] Purchase product failed: $e');
      return null;
    }
  }

  /// Purchase a package. Returns CustomerInfo if successful, null otherwise.
  static Future<CustomerInfo?> purchasePackageRaw(Package package) async {
    if (kIsWeb) return null;
    if (!_initialized) await init();
    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RevenueCat] User cancelled purchase');
      } else {
        debugPrint('[RevenueCat] Purchase exception: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('[RevenueCat] Purchase failed: $e');
      return null;
    }
  }

  /// Purchase a package. Returns true if entitlement became active or transaction was completed.
  static Future<bool> purchasePackage(Package package) async {
    final customerInfo = await purchasePackageRaw(package);
    if (customerInfo == null) return false;
    final hasActive = customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    final hasNonEmptyEntitlements = customerInfo.entitlements.active.isNotEmpty;
    final hasLatestTransaction = customerInfo.nonSubscriptionTransactions.isNotEmpty ||
        customerInfo.allPurchasedProductIdentifiers.isNotEmpty;
    return hasActive || hasNonEmptyEntitlements || hasLatestTransaction;
  }

  /// Restore previous purchases.
  static Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    if (!_initialized) await init();
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('[RevenueCat] Restore purchases error: $e');
      return false;
    }
  }
}
