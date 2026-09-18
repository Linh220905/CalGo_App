import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
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
                  // Top Header: Language Selector
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

                  // Middle Section: Welcome, Logo, Mascot, Info Card
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.contentHorizontalPadding,
                      ),
                      child: Column(
                        children: [
                          // 1. Welcome + Logo at top
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.welcomeTo,
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
                          SizedBox(height: metrics.topSectionGap),

                          // 2. Mascot + Overlapping Card in Stack (exact same structure as HTML)
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: constraints.maxWidth -
                                    (metrics.contentHorizontalPadding * 2),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.topCenter,
                                  children: [
                                    // Mascot placed at top of stack
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
                                      child: Image.asset(
                                        'assets/images/apple_mascot/apple_hello.png',
                                        height: metrics.mascotImageHeight,
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    // Card placed overlapping mascot bottom
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: metrics.mascotImageHeight -
                                            metrics.mascotOverlap,
                                      ),
                                      child: Animate(
                                        effects: [
                                          FadeEffect(
                                              duration: 350.ms, delay: 80.ms),
                                          SlideEffect(
                                            begin: const Offset(0, 8),
                                            end: Offset.zero,
                                            duration: 350.ms,
                                            delay: 80.ms,
                                          ),
                                        ],
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              metrics.cardPadding),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color: const Color(0xFFF4F4F5),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.07),
                                                blurRadius: 30,
                                                offset: const Offset(0, 10),
                                              ),
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _BenefitRow(
                                                icon: Icons.camera_alt_rounded,
                                                title: s.snapPhotoAiTitle,
                                                desc: s.snapPhotoAiDesc,
                                                metrics: metrics,
                                              ),
                                              SizedBox(
                                                  height: metrics.benefitGap),
                                              _BenefitRow(
                                                icon: Icons.bar_chart_rounded,
                                                title: s.trackEasilyTitle,
                                                desc: s.trackEasilyDesc,
                                                metrics: metrics,
                                              ),
                                              SizedBox(
                                                  height: metrics.benefitGap),
                                              _BenefitRow(
                                                icon: Icons.flag_rounded,
                                                title: s.reachGoalsTitle,
                                                desc: s.reachGoalsDesc,
                                                metrics: metrics,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
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
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => context.push('/login'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 13.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: s.alreadyHaveAccount),
                                    TextSpan(
                                      text: s.loginAction,
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _HeroCardContent extends StatelessWidget {
  final _HeroLayoutMetrics metrics;
  final String snapTitle;
  final String snapDescription;
  final String trackTitle;
  final String trackDescription;
  final String goalsTitle;
  final String goalsDescription;

  const _HeroCardContent({
    required this.metrics,
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
        // Mascot apple hello standing right on top of card
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
              alignment: Alignment.topCenter,
              heightFactor: 0.60,
              child: Image.asset(
                'assets/images/apple_mascot/apple_hello.png',
                height: metrics.mascotImageHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Info card centered
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
                  color: Colors.black.withValues(alpha: 0.05),
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
  final double topSectionGap;
  final double mascotImageHeight;
  final double mascotOverlap;
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
    required this.topSectionGap,
    required this.mascotImageHeight,
    required this.mascotOverlap,
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
        headerVerticalPadding: 8,
        contentHorizontalPadding: 16,
        buttonHorizontalPadding: 16,
        buttonTopPadding: 2,
        buttonBottomPadding: 4,
        buttonHeight: 46,
        welcomeFontSize: 13,
        logoGap: 2,
        logoHeight: 48,
        topSectionGap: 2,
        mascotImageHeight: 180,
        mascotOverlap: 30,
        cardPadding: 10,
        benefitGap: 5,
        benefitIconSize: 18,
        benefitIconGap: 8,
        benefitTitleSize: 13.5,
        benefitDescriptionSize: 11.5,
      );
    }

    if (compact) {
      return const _HeroLayoutMetrics(
        headerHorizontalPadding: 18,
        headerVerticalPadding: 10,
        contentHorizontalPadding: 20,
        buttonHorizontalPadding: 20,
        buttonTopPadding: 4,
        buttonBottomPadding: 6,
        buttonHeight: 48,
        welcomeFontSize: 14,
        logoGap: 2,
        logoHeight: 54,
        topSectionGap: 4,
        mascotImageHeight: 220,
        mascotOverlap: 38,
        cardPadding: 12,
        benefitGap: 6,
        benefitIconSize: 19,
        benefitIconGap: 10,
        benefitTitleSize: 14,
        benefitDescriptionSize: 12,
      );
    }

    return const _HeroLayoutMetrics(
      headerHorizontalPadding: 20,
      headerVerticalPadding: 12,
      contentHorizontalPadding: 24,
      buttonHorizontalPadding: 24,
      buttonTopPadding: 6,
      buttonBottomPadding: 10,
      buttonHeight: 52,
      welcomeFontSize: 14.5,
      logoGap: 3,
      logoHeight: 60,
      topSectionGap: 6,
      mascotImageHeight: 250,
      mascotOverlap: 45,
      cardPadding: 16,
      benefitGap: 10,
      benefitIconSize: 20,
      benefitIconGap: 12,
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
