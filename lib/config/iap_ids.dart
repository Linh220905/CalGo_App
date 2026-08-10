/// Product IDs for Google Play In-App Products.
///
/// Match products defined in Google Play Console → In-app products.
/// ENV prod ID mapping for dev vs production.
class IapIds {
  IapIds._();

  static const String devSuffix = '.dev';

  /// Auto-renewable subscriptions.  Create the same IDs in Google Play
  /// Console and App Store Connect, then mirror them in backend .env.
  static const String premiumWeekly = 'calgo_premium_weekly';
  static const String premiumMonthly = 'calgo_premium_monthly';
  static const String premiumAnnual = 'calgo_premium_annual';

  static const Set<String> premiumProducts = {
    premiumWeekly,
    premiumMonthly,
    premiumAnnual,
  };

  static bool isPremiumProduct(String productId) =>
      premiumProducts.contains(productId);

  /// Credit packages mapping to Google Play product IDs.
  ///
  /// Key = package id (used by backend), Value = Google Play SKU.
  static Map<String, String> get creditProducts => {
        'pkg_10': 'credit_10',
        'pkg_25': 'credit_25',
        'pkg_100': 'credit_100',
      };

  static String productId(String packageId, {bool isDev = false}) {
    final base = creditProducts[packageId] ?? packageId;
    if (isDev) return '$base$devSuffix';
    return base;
  }

  static String productIdForCreditAmount(int creditAmount,
      {bool isDev = false}) {
    final base = 'credit_$creditAmount';
    return isDev ? '$base$devSuffix' : base;
  }
}
