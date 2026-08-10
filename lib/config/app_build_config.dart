/// Build-time switches for the Android product flavors.
///
/// The value is supplied by the flavor build command, so switching between
/// testing and production never requires editing Dart source files.
class AppBuildConfig {
  static const String flavor = String.fromEnvironment(
    'CALGO_FLAVOR',
    defaultValue: 'production',
  );

  static const bool isTesting = flavor == 'testing';
  static const bool isProduction = !isTesting;

  /// Testing is a free QA build. The production build always uses the real
  /// server entitlement and Google Play Billing flow.
  static const bool premiumFreeForTesting = isTesting;
  static const bool googlePlayBillingEnabled = isProduction;

  /// AdMob identifiers are injected only for production builds. Keeping an
  /// empty default makes a local production build safe until real AdMob IDs
  /// are configured; testing never initializes the ads SDK.
  static const String admobAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: '',
  );
  static const String admobBannerUnitId = String.fromEnvironment(
    'ADMOB_BANNER_UNIT_ID',
    defaultValue: '',
  );

  static const bool adsEnabled =
      isProduction && admobAppId != '' && admobBannerUnitId != '';

  static bool hasPremiumAccess({required bool serverEntitled}) =>
      premiumFreeForTesting || serverEntitled;
}
