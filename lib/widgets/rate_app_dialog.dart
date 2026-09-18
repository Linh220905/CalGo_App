import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../services/review_service.dart';

/// App Store Style 5-Star Rating Dialog matching benchmark design
class RateAppDialog extends StatefulWidget {
  const RateAppDialog({super.key});

  @override
  State<RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog> {
  int _selectedStars = 0;

  Future<void> _handleStarTap(int stars) async {
    HapticFeedback.mediumImpact();
    setState(() => _selectedStars = stars);
    await Future.delayed(const Duration(milliseconds: 250));

    await ReviewService.markRated();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (stars >= 4) {
      await ReviewService.openStoreListingOrNative();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;

    final dialogBg = isDark ? const Color(0xFF1E1C24) : const Color(0xFFF1F1F5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);
    final textSubtitle =
        isDark ? const Color(0xFF9E9DA8) : const Color(0xFF4A4A52);
    const starBlue = Color(0xFF007AFF); // iOS Blue

    return Dialog(
      backgroundColor: dialogBg,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon Mascot in rounded squircle
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/images/google_play_icon_512.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title (e.g. "Bạn có thích CalGo không?" / "Do you enjoy CalGo?")
            Text(
              s.rateAppTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle (Dynamic: Google Play on Android vs App Store on iOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                defaultTargetPlatform == TargetPlatform.android
                    ? s.rateAppSubtitleAndroid
                    : s.rateAppSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSubtitle,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 5 iOS-style Blue Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                final isFilled = starNumber <= _selectedStars;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleStarTap(starNumber),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 34,
                      color: starBlue,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // Subtle divider
            Divider(
              height: 1,
              thickness: 0.8,
              color: isDark ? const Color(0xFF2C2A36) : const Color(0xFFE2E2E8),
            ),
            const SizedBox(height: 10),

            // "Not now" / "Để sau" Button
            TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 38),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                s.rateAppLater,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: starBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
