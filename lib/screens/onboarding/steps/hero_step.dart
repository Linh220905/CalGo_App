import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/language_selector.dart';

class HeroStep extends StatelessWidget {
  const HeroStep({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final requestedTextScale =
                MediaQuery.textScalerOf(context).scale(1);
            final metrics = _HeroLayoutMetrics.from(
              constraints: constraints,
              requestedTextScale: requestedTextScale,
            );

            // Large system text still gets a useful increase, but it cannot
            // push the primary action outside a short logical viewport.
            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.headerHorizontalPadding,
                      vertical: metrics.headerVerticalPadding,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [LanguageSelectorButton(isDark: false)],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.contentHorizontalPadding,
                      ),
                      // This only scales on unusually short devices or with a
                      // long translation. Regular phones keep authored sizes.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: constraints.maxWidth -
                              (metrics.contentHorizontalPadding * 2),
                          child: _HeroContent(
                            metrics: metrics,
                            welcomeText: s.welcomeTo,
                            snapTitle: s.snapPhotoAiTitle,
                            snapDescription: s.snapPhotoAiDesc,
                            trackTitle: s.trackEasilyTitle,
                            trackDescription: s.trackEasilyDesc,
                            goalsTitle: s.reachGoalsTitle,
                            goalsDescription: s.reachGoalsDesc,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      metrics.buttonHorizontalPadding,
                      metrics.buttonTopPadding,
                      metrics.buttonHorizontalPadding,
                      metrics.buttonBottomPadding,
                    ),
                    child: Animate(
                      effects: [
                        FadeEffect(duration: 350.ms, delay: 160.ms),
                        SlideEffect(
                          begin: const Offset(0, 8),
                          end: Offset.zero,
                          duration: 350.ms,
                          delay: 160.ms,
                        ),
                      ],
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: metrics.buttonHeight,
                          child: ElevatedButton(
                            key: const Key('hero_get_started_button'),
                            onPressed: () =>
                                context.read<OnboardingProvider>().nextStep(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                              textStyle: GoogleFonts.beVietnamPro(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(s.getStarted, maxLines: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final _HeroLayoutMetrics metrics;
  final String welcomeText;
  final String snapTitle;
  final String snapDescription;
  final String trackTitle;
  final String trackDescription;
  final String goalsTitle;
  final String goalsDescription;

  const _HeroContent({
    required this.metrics,
    required this.welcomeText,
    required this.snapTitle,
    required this.snapDescription,
    required this.trackTitle,
    required this.trackDescription,
    required this.goalsTitle,
    required this.goalsDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            Text(
              welcomeText,
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: metrics.welcomeFontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: metrics.logoGap),
            Image.asset(
              'assets/images/CalGo.png',
              height: metrics.logoHeight,
              fit: BoxFit.contain,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: -8, end: 0, duration: 350.ms),
        SizedBox(height: metrics.sectionGap),
        Animate(
          effects: [
            FadeEffect(duration: 400.ms),
            ScaleEffect(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              duration: 450.ms,
              curve: Curves.easeOutCubic,
            ),
          ],
          child: ClipRect(
            child: Align(
              alignment: Alignment.center,
              heightFactor: 0.55,
              child: Image.asset(
                'assets/images/apple_mascot/apple_hello.png',
                height: metrics.mascotImageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: metrics.sectionGap),
        Animate(
          effects: [
            FadeEffect(duration: 350.ms, delay: 80.ms),
            SlideEffect(
              begin: const Offset(0, 8),
              end: Offset.zero,
              duration: 350.ms,
              delay: 80.ms,
            ),
          ],
          child: Container(
            padding: EdgeInsets.all(metrics.cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _BenefitRow(
                  icon: Icons.camera_alt_rounded,
                  title: snapTitle,
                  desc: snapDescription,
                  metrics: metrics,
                ),
                SizedBox(height: metrics.benefitGap),
                _BenefitRow(
                  icon: Icons.bar_chart_rounded,
                  title: trackTitle,
                  desc: trackDescription,
                  metrics: metrics,
                ),
                SizedBox(height: metrics.benefitGap),
                _BenefitRow(
                  icon: Icons.flag_rounded,
                  title: goalsTitle,
                  desc: goalsDescription,
                  metrics: metrics,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroLayoutMetrics {
  final double headerHorizontalPadding;
  final double headerVerticalPadding;
  final double contentHorizontalPadding;
  final double buttonHorizontalPadding;
  final double buttonTopPadding;
  final double buttonBottomPadding;
  final double buttonHeight;
  final double welcomeFontSize;
  final double logoGap;
  final double logoHeight;
  final double mascotImageHeight;
  final double sectionGap;
  final double cardPadding;
  final double benefitGap;
  final double benefitIconSize;
  final double benefitIconGap;
  final double benefitTitleSize;
  final double benefitDescriptionSize;

  const _HeroLayoutMetrics({
    required this.headerHorizontalPadding,
    required this.headerVerticalPadding,
    required this.contentHorizontalPadding,
    required this.buttonHorizontalPadding,
    required this.buttonTopPadding,
    required this.buttonBottomPadding,
    required this.buttonHeight,
    required this.welcomeFontSize,
    required this.logoGap,
    required this.logoHeight,
    required this.mascotImageHeight,
    required this.sectionGap,
    required this.cardPadding,
    required this.benefitGap,
    required this.benefitIconSize,
    required this.benefitIconGap,
    required this.benefitTitleSize,
    required this.benefitDescriptionSize,
  });

  factory _HeroLayoutMetrics.from({
    required BoxConstraints constraints,
    required double requestedTextScale,
  }) {
    final compact = constraints.maxHeight < 720 ||
        constraints.maxWidth < 360 ||
        requestedTextScale > 1.15;
    final veryCompact =
        constraints.maxHeight < 600 || constraints.maxWidth < 330;

    if (veryCompact) {
      return const _HeroLayoutMetrics(
        headerHorizontalPadding: 16,
        headerVerticalPadding: 3,
        contentHorizontalPadding: 16,
        buttonHorizontalPadding: 16,
        buttonTopPadding: 4,
        buttonBottomPadding: 10,
        buttonHeight: 50,
        welcomeFontSize: 13,
        logoGap: 2,
        logoHeight: 44,
        mascotImageHeight: 188,
        sectionGap: 2,
        cardPadding: 12,
        benefitGap: 7,
        benefitIconSize: 19,
        benefitIconGap: 10,
        benefitTitleSize: 14,
        benefitDescriptionSize: 12,
      );
    }

    if (compact) {
      return const _HeroLayoutMetrics(
        headerHorizontalPadding: 18,
        headerVerticalPadding: 4,
        contentHorizontalPadding: 20,
        buttonHorizontalPadding: 20,
        buttonTopPadding: 6,
        buttonBottomPadding: 12,
        buttonHeight: 52,
        welcomeFontSize: 14,
        logoGap: 3,
        logoHeight: 52,
        mascotImageHeight: 234,
        sectionGap: 4,
        cardPadding: 14,
        benefitGap: 8,
        benefitIconSize: 20,
        benefitIconGap: 12,
        benefitTitleSize: 14.5,
        benefitDescriptionSize: 12.5,
      );
    }

    return const _HeroLayoutMetrics(
      headerHorizontalPadding: 20,
      headerVerticalPadding: 8,
      contentHorizontalPadding: 24,
      buttonHorizontalPadding: 24,
      buttonTopPadding: 8,
      buttonBottomPadding: 20,
      buttonHeight: 58,
      welcomeFontSize: 15,
      logoGap: 4,
      logoHeight: 62,
      mascotImageHeight: 300,
      sectionGap: 8,
      cardPadding: 18,
      benefitGap: 12,
      benefitIconSize: 22,
      benefitIconGap: 14,
      benefitTitleSize: 15,
      benefitDescriptionSize: 13,
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final _HeroLayoutMetrics metrics;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.desc,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: metrics.benefitIconSize, color: AppColors.ink),
        SizedBox(width: metrics.benefitIconGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.beVietnamPro(
                  fontSize: metrics.benefitTitleSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.beVietnamPro(
                  fontSize: metrics.benefitDescriptionSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
