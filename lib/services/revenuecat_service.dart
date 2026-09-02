import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._();

  static const String _envApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'test_caqXpahYGVvFqCtaYqdb0bZQZKt',
  );
  static const String _envIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: '',
  );
  static const String _envAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const String entitlementId = 'calgo_pro';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initialize RevenueCat SDK with the signed-in User ID.
  static Future<void> init({String? appUserId}) async {
    if (_initialized) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final apiKey = _getApiKey();
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
    if (Platform.isIOS && _envIosApiKey.isNotEmpty) {
      return _envIosApiKey;
    }
    if (Platform.isAndroid && _envAndroidApiKey.isNotEmpty) {
      return _envAndroidApiKey;
    }
    return _envApiKey;
  }

  /// Set user ID after login.
  static Future<void> logIn(String userId) async {
    if (!_initialized) await init(appUserId: userId);
    try {
      final customerInfo = await Purchases.logIn(userId);
      debugPrint('[RevenueCat] Logged in user: $userId, active entitlements: ${customerInfo.customerInfo.entitlements.active.keys}');
    } catch (e) {
      debugPrint('[RevenueCat] Login error: $e');
    }
  }

  /// Reset identity on logout.
  static Future<void> logOut() async {
    if (!_initialized) return;
    try {
      await Purchases.logOut();
      debugPrint('[RevenueCat] Logged out successfully');
    } catch (e) {
      debugPrint('[RevenueCat] Logout error: $e');
    }
  }

  /// Check if the user currently holds an active premium entitlement.
  static Future<bool> isPremium() async {
    if (!_initialized) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('[RevenueCat] Check premium error: $e');
      return false;
    }
  }

  /// Fetch current offerings (Weekly, Monthly, Annual packages).
  static Future<Offerings?> getOfferings() async {
    if (!_initialized) await init();
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('[RevenueCat] Fetch offerings error: $e');
      return null;
    }
  }

  /// Purchase a package. Returns true if entitlement became active.
  static Future<bool> purchasePackage(Package package) async {
    if (!_initialized) await init();
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } on PurchasesException catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RevenueCat] User cancelled purchase');
      } else {
        debugPrint('[RevenueCat] Purchase exception: ${e.message}');
      }
      return false;
    } catch (e) {
      debugPrint('[RevenueCat] Purchase failed: $e');
      return false;
    }
  }

  /// Restore previous purchases.
  static Future<bool> restorePurchases() async {
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
