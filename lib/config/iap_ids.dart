/// Product IDs for Google Play In-App Products.
///
/// Match products defined in Google Play Console → In-app products.
/// ENV prod ID mapping for dev vs production.
class IapIds {
  IapIds._();

  static const String devSuffix = '.dev';

  /// Credit packages mapping to Google Play product IDs.
  ///
  /// Key = package id (used by backend), Value = Google Play SKU.
  static Map<String, String> get creditProducts => {
        'pkg_10': 'credit_10',
        'pkg_30': 'credit_30',
        'pkg_100': 'credit_100',
      };

  static String productId(String packageId, {bool isDev = false}) {
    final base = creditProducts[packageId] ?? packageId;
    if (isDev) return '$base$devSuffix';
    return base;
  }
}
