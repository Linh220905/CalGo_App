import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/rate_app_dialog.dart';

class ReviewService {
  ReviewService._();

  static const String _keyHasRated = 'has_rated_app';
  static const String _keyLastPromptTimestamp = 'last_review_prompt_timestamp';
  static const String _keyPromptCount = 'review_prompt_count';

  static const int _cooldownDays = 3;
  static const int _maxPrompts = 4;

  static const String _androidPackageName = 'com.calgo.calgo';
  static const String _iosAppId = '6741793741'; // App Store ID if published

  /// Check whether we can prompt the user for rating
  static Future<bool> shouldPromptReview() async {
    if (kIsWeb) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRated = prefs.getBool(_keyHasRated) ?? false;
      if (hasRated) return false;

      final count = prefs.getInt(_keyPromptCount) ?? 0;
      if (count >= _maxPrompts) return false;

      final lastTimestamp = prefs.getInt(_keyLastPromptTimestamp) ?? 0;
      if (lastTimestamp > 0) {
        final lastDate = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
        final diffDays = DateTime.now().difference(lastDate).inDays;
        if (diffDays < _cooldownDays) return false;
      }

      return true;
    } catch (e) {
      debugPrint('[ReviewService] Error checking shouldPromptReview: $e');
      return false;
    }
  }

  /// Mark that rating was completed (prevent future popups)
  static Future<void> markRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasRated, true);
    } catch (_) {}
  }

  /// Mark prompt timestamp and increment count
  static Future<void> recordPromptShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_keyPromptCount) ?? 0) + 1;
      await prefs.setInt(_keyPromptCount, count);
      await prefs.setInt(
        _keyLastPromptTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  /// Opens official store listing or triggers native OS in-app review dialog
  static Future<void> openStoreListingOrNative() async {
    try {
      final inAppReview = InAppReview.instance;
      // On Google Play / iOS, requestReview is rate-limited by OS.
      // If native request does not open store, open direct store listing.
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await _openDirectStoreUrl();
      }
    } catch (e) {
      debugPrint('[ReviewService] Native in-app review fallback to url: $e');
      await _openDirectStoreUrl();
    }
  }

  /// Open Google Play or App Store directly via URL
  static Future<void> _openDirectStoreUrl() async {
    try {
      final inAppReview = InAppReview.instance;
      await inAppReview.openStoreListing(appStoreId: _iosAppId);
    } catch (_) {
      try {
        final Uri url;
        if (Platform.isAndroid) {
          url = Uri.parse('market://details?id=$_androidPackageName');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            return;
          }
          final webUrl = Uri.parse('https://play.google.com/store/apps/details?id=$_androidPackageName');
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else if (Platform.isIOS) {
          url = Uri.parse('https://apps.apple.com/app/id$_iosAppId?action=write-review');
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('[ReviewService] open direct store url error: $e');
      }
    }
  }

  /// Shows custom 5-star rating dialog in app if eligible
  static Future<void> showRatingDialog(BuildContext context, {String source = 'scan'}) async {
    if (!context.mounted) return;
    final canPrompt = await shouldPromptReview();
    if (!canPrompt || !context.mounted) return;

    await recordPromptShown();
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const RateAppDialog(),
    );
  }

  /// Request rating popup for first scan or specific milestone
  static Future<void> requestFirstScanReview(BuildContext? context) async {
    if (context != null && context.mounted) {
      await showRatingDialog(context, source: 'first_scan');
    }
  }

  /// Legacy support
  static Future<void> requestReviewPrompt({String source = 'scan', BuildContext? context}) async {
    if (context != null && context.mounted) {
      await showRatingDialog(context, source: source);
    }
  }
}
