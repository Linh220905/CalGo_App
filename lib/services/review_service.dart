import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  ReviewService._();

  static const String _keyHasPromptedFirstScan = 'has_prompted_first_scan_review';

  /// Requests in-app review popup from OS (Google Play In-App Review / iOS SKStoreReviewController)
  /// when the user finishes their first scan.
  static Future<void> requestFirstScanReview() async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPrompted = prefs.getBool(_keyHasPromptedFirstScan) ?? false;
      if (hasPrompted) return;

      final inAppReview = InAppReview.instance;
      final isAvailable = await inAppReview.isAvailable();

      if (isAvailable) {
        // Mark as prompted so we don't repeat on subsequent scans
        await prefs.setBool(_keyHasPromptedFirstScan, true);
        await inAppReview.requestReview();
        debugPrint('[ReviewService] Native in-app review requested successfully.');
      }
    } catch (e) {
      debugPrint('[ReviewService] Error requesting review: $e');
    }
  }
}
