import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  ReviewService._();

  static const String _keyHasPromptedReview = 'has_prompted_in_app_review';

  /// Requests in-app review popup from OS (Google Play In-App Review / iOS SKStoreReviewController)
  /// during onboarding (e.g. after referral question) or on first scan.
  /// If user has already been prompted or reviewed, it will safely no-op.
  static Future<void> requestReviewPrompt({String source = 'scan'}) async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPrompted = prefs.getBool(_keyHasPromptedReview) ?? false;
      if (hasPrompted) return;

      final inAppReview = InAppReview.instance;
      final isAvailable = await inAppReview.isAvailable();

      if (isAvailable) {
        // Mark as prompted so we don't repeat in onboarding or subsequent scans
        await prefs.setBool(_keyHasPromptedReview, true);
        await inAppReview.requestReview();
        debugPrint('[ReviewService] Native in-app review requested from $source.');
      }
    } catch (e) {
      debugPrint('[ReviewService] Error requesting review ($source): $e');
    }
  }

  /// Legacy helper method forwarding to requestReviewPrompt
  static Future<void> requestFirstScanReview() =>
      requestReviewPrompt(source: 'first_scan');
}
