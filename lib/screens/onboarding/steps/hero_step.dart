import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../config/app_build_config.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/language_selector.dart';

class HeroStep extends StatefulWidget {
  const HeroStep({super.key});

  @override
  State<HeroStep> createState() => _HeroStepState();
}

class _HeroStepState extends State<HeroStep> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _laserController;
  late final AnimationController _pingController;
  late final AnimationController _textFadeController;

  Timer? _aiMessageTimer;
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    // 1. Entrance 3D emergence animation (1.8s smooth cubic)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 2. Slow green laser line scan (4.2s infinite easeInOut loop)
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    // 3. Pulsing green dot ping animation (1.5s infinite loop)
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 4. Text fade transition controller (350ms)
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );

    // Start 3D emergence after brief initial white hold (skip delay during widget test)
    if (AppBuildConfig.isTesting) {
      _entryController.value = 1.0;
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _entryController.forward();
        }
      });

      // Cycle AI scanning messages every 2.4 seconds
      _aiMessageTimer = Timer.periodic(const Duration(milliseconds: 2400), (timer) {
        if (!mounted) return;
        _cycleNextMessage();
      });
    }
  }

  void _cycleNextMessage() {
    _textFadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentMessageIndex = (_currentMessageIndex + 1) % 5;
      });
      _textFadeController.forward();
    });
  }

  @override
  void dispose() {
    _aiMessageTimer?.cancel();
    _entryController.dispose();
    _laserController.dispose();
    _pingController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  List<String> _getAiMessages(AppSettingsProvider settings) {
    final s = settings.strings;
    // Map to existing localized scanning strings in AppLocalizations
    return [
      s.scanProcessingRecognizing,
      s.scanProcessingRecognized,
      s.scanProcessingIngredients,
      s.scanProcessingNutrition,
      s.scanProcessingCalories,
    ];
  }

  String _getHeroTitle(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return 'Theo dõi calo\ndễ dàng hơn bao giờ hết';
      case 'es':
        return 'Seguimiento de calorías\nfácil y rápido';
      case 'fr':
        return 'Le suivi des calories\nen toute simplicité';
      case 'ja':
        return 'カロリー記録を\nもっと手軽に';
      case 'ko':
        return '칼로리 기록을\n쉽고 간편하게';
      case 'pt':
        return 'Contagem de calorias\nmais fácil do que nunca';
      case 'ru':
        return 'Подсчет калорий\nпроще простого';
      case 'zh':
        return '轻松记录\n每一餐卡路里';
      case 'ar':
        return 'تتبع السعرات الحرارية\nأسهل من أي وقت مضى';
      case 'bn':
        return 'ক্যালোরি ট্র্যাকিং\nএখন আরও সহজ';
      case 'hi':
        return 'कैलोरी ट्रैकिंग\nअब और भी आसान';
      case 'ro':
        return 'Urmărirea caloriilor\nmai simplă ca niciodată';
      case 'en':
      default:
        return 'Calorie tracking\nmade easy';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final aiMessages = _getAiMessages(settings);
    final currentStatusText = aiMessages[_currentMessageIndex % aiMessages.length];
    final heroTitle = _getHeroTitle(settings.languageCode);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metrics = _HeroLayoutMetrics.from(constraints: constraints);

            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: Column(
                children: [
                  // Top Action Bar: Language Selector
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

                  // Middle Section: 3D Perspective iPhone Pro Mockup + Food Scanner
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _entryController,
                        builder: (context, child) {
                          final curvedVal = CurvedAnimation(
                            parent: _entryController,
                            curve: const Cubic(0.16, 1.0, 0.3, 1.0),
                          ).value;

                          // 3D Matrix transform matching preview:
                          // start: translateY(140px), rotateX(32deg), rotateY(-8deg), rotateZ(3deg), scale(0.82)
                          // end: translateY(0), rotateX(0deg), rotateY(0deg), rotateZ(0deg), scale(1.0)
                          final translateY = 140.0 * (1.0 - curvedVal);
                          final rotateX = (32.0 * (1.0 - curvedVal)) * (3.14159265359 / 180.0);
                          final rotateY = (-8.0 * (1.0 - curvedVal)) * (3.14159265359 / 180.0);
                          final rotateZ = (3.0 * (1.0 - curvedVal)) * (3.14159265359 / 180.0);
                          final scale = 0.82 + (0.18 * curvedVal);
                          final opacity = curvedVal.clamp(0.0, 1.0);

                          final matrix = Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..translate(0.0, translateY, 0.0)
                            ..scale(scale, scale, 1.0)
                            ..rotateX(rotateX)
                            ..rotateY(rotateY)
                            ..rotateZ(rotateZ);

                          return Opacity(
                            opacity: opacity,
                            child: Transform(
                              transform: matrix,
                              alignment: Alignment.bottomCenter,
                              child: child,
                            ),
                          );
                        },
                        child: _IPhoneProMockup(
                          metrics: metrics,
                          laserController: _laserController,
                          pingController: _pingController,
                          textFadeController: _textFadeController,
                          statusText: currentStatusText,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Section: Headline + Get Started Button + Login Action
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      metrics.bottomHorizontalPadding,
                      metrics.bottomTopPadding,
                      metrics.bottomHorizontalPadding,
                      metrics.bottomPadding,
                    ),
                    child: Animate(
                      effects: [
                        FadeEffect(
                          duration: 900.ms,
                          delay: 450.ms,
                          curve: Curves.easeOutCubic,
                        ),
                        SlideEffect(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                          duration: 900.ms,
                          delay: 450.ms,
                          curve: Curves.easeOutCubic,
                        ),
                      ],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Headline
                          Text(
                            heroTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: metrics.titleFontSize,
                              fontWeight: FontWeight.w800,
                              height: 1.20,
                              letterSpacing: -0.6,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: metrics.buttonSpacing),

                          // Button Get Started
                          Container(
                            width: double.infinity,
                            height: metrics.buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              key: const Key('hero_get_started_button'),
                              onPressed: () =>
                                  context.read<OnboardingProvider>().nextStep(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.ink,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: metrics.buttonFontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(s.getStarted, maxLines: 1),
                              ),
                            ),
                          ),
                          SizedBox(height: metrics.loginRowSpacing),

                          // Already have an account? Sign In
                          GestureDetector(
                            onTap: () => context.push('/login'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: metrics.loginFontSize,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: '${s.alreadyHaveAccount} '),
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

/// iPhone 15/16 Pro Phone Mockup with Dynamic Island, Laser Scan & Live AI Status Pill
class _IPhoneProMockup extends StatelessWidget {
  final _HeroLayoutMetrics metrics;
  final AnimationController laserController;
  final AnimationController pingController;
  final AnimationController textFadeController;
  final String statusText;

  const _IPhoneProMockup({
    required this.metrics,
    required this.laserController,
    required this.pingController,
    required this.textFadeController,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Physical Buttons on side
        Positioned(
          left: -3.5,
          top: metrics.mockupHeight * 0.18,
          child: Container(
            width: 4,
            height: metrics.mockupHeight * 0.082,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Positioned(
          left: -3.5,
          top: metrics.mockupHeight * 0.28,
          child: Container(
            width: 4,
            height: metrics.mockupHeight * 0.082,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Positioned(
          right: -3.5,
          top: metrics.mockupHeight * 0.22,
          child: Container(
            width: 4,
            height: metrics.mockupHeight * 0.118,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),

        // Inner Phone Outer Titanium Bezel & Frame
        Container(
          width: metrics.mockupWidth,
          height: metrics.mockupHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(metrics.phoneCornerRadius),
            border: Border.all(
              color: const Color(0xFF18181A),
              width: metrics.phoneBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 50,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.12),
                blurRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              metrics.phoneCornerRadius - metrics.phoneBorderWidth,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Food Photo Image (clean dish)
                Image.asset(
                  'assets/images/onboarding_hero_scan.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.04), // center 48%
                ),

                // 2. Programmatic Scanning Green Laser Beam & Line
                AnimatedBuilder(
                  animation: laserController,
                  builder: (context, child) {
                    // Keyframe sweep mapping:
                    // 0% -> top 15%, opacity 0
                    // 8% -> opacity 1
                    // 50% -> top 78%, opacity 1
                    // 92% -> opacity 1
                    // 100% -> top 15%, opacity 0
                    final val = laserController.value;
                    double topFactor;
                    double laserOpacity;

                    if (val <= 0.5) {
                      final p = val / 0.5;
                      final ease = Curves.easeInOut.transform(p);
                      topFactor = 0.15 + (0.63 * ease);
                    } else {
                      final p = (val - 0.5) / 0.5;
                      final ease = Curves.easeInOut.transform(p);
                      topFactor = 0.78 - (0.63 * ease);
                    }

                    if (val < 0.08) {
                      laserOpacity = val / 0.08;
                    } else if (val > 0.92) {
                      laserOpacity = (1.0 - val) / 0.08;
                    } else {
                      laserOpacity = 1.0;
                    }

                    return Positioned(
                      top: metrics.mockupHeight * topFactor,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: laserOpacity.clamp(0.0, 1.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Upward gradient glow beam
                            Positioned(
                              bottom: 1.8,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 38,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0x304ADE80),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Thin 1.8px high green laser line with soft neon glow
                            Container(
                              height: 1.8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ADE80).withValues(alpha: 0.9),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4ADE80).withValues(alpha: 0.45),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 3. Bottom Status Overlay matching Web ScanScreen.tsx
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      metrics.mockupHeight * 0.07,
                      12,
                      metrics.mockupHeight * 0.038,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.42, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pulsing Green Dot
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ping expanding ring
                              AnimatedBuilder(
                                animation: pingController,
                                builder: (context, _) {
                                  final v = pingController.value;
                                  final pingScale = 1.0 + (1.2 * v);
                                  final pingOpacity = (1.0 - v).clamp(0.0, 0.75);

                                  return Transform.scale(
                                    scale: pingScale,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF4ADE80)
                                            .withValues(alpha: pingOpacity),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Core solid bright dot
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF4ADE80),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ADE80).withValues(alpha: 0.9),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Animated Text with Smooth Fade Transition
                        Flexible(
                          child: AnimatedBuilder(
                            animation: textFadeController,
                            builder: (context, child) {
                              final fadeVal = textFadeController.value;
                              return Opacity(
                                opacity: fadeVal,
                                child: Transform.translate(
                                  offset: Offset(0, 3.0 * (1.0 - fadeVal)),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: metrics.statusFontSize,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0, 1.5),
                                    blurRadius: 6,
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

                // 4. Dynamic Island Notch on Top
                Positioned(
                  top: metrics.notchTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: metrics.notchWidth,
                      height: metrics.notchHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // Camera lens reflection on right
                          Positioned(
                            right: metrics.notchWidth * 0.16,
                            top: (metrics.notchHeight - 6.5) / 2,
                            child: Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF09121D),
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
      ],
    );
  }
}

/// Adaptive Layout Metrics for all phone screen dimensions
class _HeroLayoutMetrics {
  final double headerHorizontalPadding;
  final double headerVerticalPadding;
  final double mockupWidth;
  final double mockupHeight;
  final double phoneCornerRadius;
  final double phoneBorderWidth;
  final double notchWidth;
  final double notchHeight;
  final double notchTop;
  final double statusFontSize;
  final double bottomHorizontalPadding;
  final double bottomTopPadding;
  final double bottomPadding;
  final double titleFontSize;
  final double buttonHeight;
  final double buttonFontSize;
  final double buttonSpacing;
  final double loginRowSpacing;
  final double loginFontSize;

  const _HeroLayoutMetrics({
    required this.headerHorizontalPadding,
    required this.headerVerticalPadding,
    required this.mockupWidth,
    required this.mockupHeight,
    required this.phoneCornerRadius,
    required this.phoneBorderWidth,
    required this.notchWidth,
    required this.notchHeight,
    required this.notchTop,
    required this.statusFontSize,
    required this.bottomHorizontalPadding,
    required this.bottomTopPadding,
    required this.bottomPadding,
    required this.titleFontSize,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.buttonSpacing,
    required this.loginRowSpacing,
    required this.loginFontSize,
  });

  factory _HeroLayoutMetrics.from({required BoxConstraints constraints}) {
    final height = constraints.maxHeight;
    final width = constraints.maxWidth;

    // iPhone aspect ratio 1242 / 2688 = 0.462
    const aspectRatio = 1242.0 / 2688.0;

    // Responsive scaling based on height and width
    final isVerySmall = height < 640;
    final isCompact = height < 740;
    final isLarge = height >= 840;

    double calculatedMockupHeight;
    if (isVerySmall) {
      calculatedMockupHeight = (height * 0.44).clamp(240.0, 290.0);
    } else if (isCompact) {
      calculatedMockupHeight = (height * 0.48).clamp(310.0, 380.0);
    } else if (isLarge) {
      calculatedMockupHeight = (height * 0.52).clamp(410.0, 480.0);
    } else {
      // standard 740..840 (e.g. iPhone 13/14/15/16: 844, 852px)
      calculatedMockupHeight = (height * 0.50).clamp(370.0, 440.0);
    }

    // Ensure width fits inside screen width with margins (allow up to 70% screen width for standard phone)
    double calculatedMockupWidth = calculatedMockupHeight * aspectRatio;
    final maxAvailableWidth = width * 0.70;
    if (calculatedMockupWidth > maxAvailableWidth) {
      calculatedMockupWidth = maxAvailableWidth;
      calculatedMockupHeight = calculatedMockupWidth / aspectRatio;
    }

    final cornerRadius = (calculatedMockupHeight * 0.102).clamp(28.0, 44.0);
    final borderWidth = (calculatedMockupWidth * 0.038).clamp(5.0, 7.5);
    final notchW = (calculatedMockupWidth * 0.36).clamp(50.0, 70.0);
    final notchH = (calculatedMockupHeight * 0.044).clamp(13.0, 18.0);
    final notchT = (calculatedMockupHeight * 0.024).clamp(7.0, 11.0);

    if (isVerySmall) {
      return _HeroLayoutMetrics(
        headerHorizontalPadding: 16,
        headerVerticalPadding: 6,
        mockupWidth: calculatedMockupWidth,
        mockupHeight: calculatedMockupHeight,
        phoneCornerRadius: cornerRadius,
        phoneBorderWidth: borderWidth,
        notchWidth: notchW,
        notchHeight: notchH,
        notchTop: notchT,
        statusFontSize: 11,
        bottomHorizontalPadding: 20,
        bottomTopPadding: 8,
        bottomPadding: 12,
        titleFontSize: 21,
        buttonHeight: 48,
        buttonFontSize: 15.5,
        buttonSpacing: 12,
        loginRowSpacing: 8,
        loginFontSize: 12.5,
      );
    }

    if (isCompact) {
      return _HeroLayoutMetrics(
        headerHorizontalPadding: 18,
        headerVerticalPadding: 8,
        mockupWidth: calculatedMockupWidth,
        mockupHeight: calculatedMockupHeight,
        phoneCornerRadius: cornerRadius,
        phoneBorderWidth: borderWidth,
        notchWidth: notchW,
        notchHeight: notchH,
        notchTop: notchT,
        statusFontSize: 12,
        bottomHorizontalPadding: 24,
        bottomTopPadding: 12,
        bottomPadding: 16,
        titleFontSize: 24,
        buttonHeight: 52,
        buttonFontSize: 16.5,
        buttonSpacing: 16,
        loginRowSpacing: 10,
        loginFontSize: 13,
      );
    }

    return _HeroLayoutMetrics(
      headerHorizontalPadding: 20,
      headerVerticalPadding: 8,
      mockupWidth: calculatedMockupWidth,
      mockupHeight: calculatedMockupHeight,
      phoneCornerRadius: cornerRadius,
      phoneBorderWidth: borderWidth,
      notchWidth: notchW,
      notchHeight: notchH,
      notchTop: notchT,
      statusFontSize: 13,
      bottomHorizontalPadding: 24,
      bottomTopPadding: 16,
      bottomPadding: 22,
      titleFontSize: 27,
      buttonHeight: 56,
      buttonFontSize: 17,
      buttonSpacing: 18,
      loginRowSpacing: 12,
      loginFontSize: 13.5,
    );
  }
}
