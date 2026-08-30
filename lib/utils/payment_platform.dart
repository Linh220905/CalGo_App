import 'package:flutter/foundation.dart';

bool get isAppleBillingPlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Rewrites localized payment copy that is shared between Android and Apple
/// builds. The purchase verification itself remains platform-specific.
String paymentCopyForPlatform(String text) {
  if (!isAppleBillingPlatform) return text;

  return text
      .replaceAll('Google Play / App Store', 'App Store')
      .replaceAll('App Store / Google Play', 'App Store')
      .replaceAll('Google Play Billing', 'App Store billing')
      .replaceAll('Google Play', 'App Store')
      .replaceAll('Android', 'iOS')
      .replaceAll(
        'https://play.google.com/store/account/subscriptions',
        'https://apps.apple.com/account/subscriptions',
      );
}
