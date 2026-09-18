import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../services/review_service.dart';

class PaceStep extends StatefulWidget {
  const PaceStep({super.key});

  @override
  State<PaceStep> createState() => _PaceStepState();
}

enum _PaceTier { slow, recommended, fast }

class _PaceStepState extends State<PaceStep> {
  // Stored in kg per week internally
  late double _lossPerWeekKg;
  bool _isImperial = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = context.read<AppSettingsProvider>();
      final provider = context.read<OnboardingProvider>();
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final countryCode = (locale.countryCode ?? '').toUpperCase();
      _isImperial = countryCode == 'US' ||
          countryCode == 'LR' ||
          countryCode == 'MM' ||
          (countryCode.isEmpty && settings.languageCode == 'en');

      _lossPerWeekKg = provider.data.lossPerWeekKg ?? 0.45; // ~1.0 lbs default
      _initialized = true;
    }
  }

  _PaceTier get _currentTier {
    final lbs = _lossPerWeekKg * 2.20462;
    if (lbs < 0.75) return _PaceTier.slow;
    if (lbs <= 1.25) return _PaceTier.recommended;
    return _PaceTier.fast;
  }

  void _selectTier(_PaceTier tier) {
    setState(() {
      switch (tier) {
        case _PaceTier.slow:
          _lossPerWeekKg = _isImperial ? 0.5 / 2.20462 : 0.25;
          break;
        case _PaceTier.recommended:
          _lossPerWeekKg = _isImperial ? 1.0 / 2.20462 : 0.50;
          break;
        case _PaceTier.fast:
          _lossPerWeekKg = _isImperial ? 1.5 / 2.20462 : 0.75;
          break;
      }
    });
    context.read<OnboardingProvider>().setLossPerWeek(_lossPerWeekKg);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final isDark = settings.isDarkMode;
    final provider = context.watch<OnboardingProvider>();
    final goal = provider.data.goalType ?? GoalType.lose;

    final bgColor = isDark ? const Color(0xFF131217) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    const orangeAccent = Color(0xFFE28454);

    // Slider min/max in current display unit
    final minVal = _isImperial ? 0.3 : 0.15;
    final maxVal = _isImperial ? 2.0 : 1.0;
    final currentDisplayVal =
        _isImperial ? _lossPerWeekKg * 2.20462 : _lossPerWeekKg;
    final clampedDisplayVal = currentDisplayVal.clamp(minVal, maxVal);

    final displayUnit = _isImperial ? 'lbs' : 'kg';
    final formattedSpeed = clampedDisplayVal.toStringAsFixed(1);

    final tier = _currentTier;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      s.paceHeadline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Subtitle / Unit label
                    Center(
                      child: Text(
                        switch (goal) {
                          GoalType.lose => s.paceSpeedSubtitle,
                          GoalType.gain => s.paceSpeedSubtitleGain,
                          GoalType.maintain => s.paceSpeedSubtitleMaintain,
                        },
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Big Display Number
                    Center(
                      child: Text(
                        '$formattedSpeed $displayUnit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Animal Icons Row (Slow - Sloth, Recommended - Rabbit, Fast - Cheetah)
                    Row(
                      children: [
                        Expanded(
                          child: _AnimalOption(
                            label: s.pacePaceSlow,
                            isSelected: tier == _PaceTier.slow,
                            isRecommended: false,
                            isDark: isDark,
                            onTap: () => _selectTier(_PaceTier.slow),
                            child: CustomPaint(
                              size: const Size(54, 44),
                              painter: _SlothPainter(
                                color: tier == _PaceTier.slow
                                    ? (isDark ? Colors.white : const Color(0xFF111111))
                                    : (isDark ? const Color(0xFF6B6878) : const Color(0xFF8E8E93)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _AnimalOption(
                            label: s.pacePaceRecommended,
                            isSelected: tier == _PaceTier.recommended,
                            isRecommended: true,
                            isDark: isDark,
                            onTap: () => _selectTier(_PaceTier.recommended),
                            child: CustomPaint(
                              size: const Size(56, 44),
                              painter: _RabbitPainter(
                                color: tier == _PaceTier.recommended
                                    ? orangeAccent
                                    : (isDark ? const Color(0xFF8B5E4A) : const Color(0xFFD49B83)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _AnimalOption(
                            label: s.pacePaceFast,
                            isSelected: tier == _PaceTier.fast,
                            isRecommended: false,
                            isDark: isDark,
                            onTap: () => _selectTier(_PaceTier.fast),
                            child: CustomPaint(
                              size: const Size(58, 44),
                              painter: _CheetahPainter(
                                color: tier == _PaceTier.fast
                                    ? (isDark ? Colors.white : const Color(0xFF111111))
                                    : (isDark ? const Color(0xFF6B6878) : const Color(0xFF8E8E93)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Custom Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.5,
                        activeTrackColor:
                            isDark ? Colors.white : const Color(0xFF111111),
                        inactiveTrackColor: isDark
                            ? const Color(0xFF2C2A36)
                            : const Color(0xFFE5E7EB),
                        thumbColor: Colors.white,
                        thumbShape: const _CustomPaceThumbShape(radius: 14),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 24),
                        overlayColor: orangeAccent.withValues(alpha: 0.1),
                      ),
                      child: Slider(
                        value: clampedDisplayVal,
                        min: minVal,
                        max: maxVal,
                        onChanged: (val) {
                          setState(() {
                            _lossPerWeekKg = _isImperial
                                ? val / 2.20462
                                : val;
                          });
                          provider.setLossPerWeek(_lossPerWeekKg);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    provider.setLossPerWeek(_lossPerWeekKg);
                    unawaited(ReviewService.requestReviewPrompt(
                      source: 'onboarding_pace',
                      context: context,
                    ));
                    provider.nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.white : const Color(0xFF141416),
                    foregroundColor:
                        isDark ? const Color(0xFF141416) : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    s.continueLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isRecommended;
  final bool isDark;
  final Widget child;
  final VoidCallback onTap;

  const _AnimalOption({
    required this.label,
    required this.isSelected,
    required this.isRecommended,
    required this.isDark,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFE28454);
    final labelColor = isRecommended
        ? (isSelected ? orangeColor : orangeColor.withValues(alpha: 0.75))
        : (isSelected
            ? (isDark ? Colors.white : const Color(0xFF111111))
            : (isDark ? const Color(0xFF6B6878) : const Color(0xFF8E8E93)));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Center(child: child),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: labelColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Slider Thumb with soft drop shadow and subtle border
class _CustomPaceThumbShape extends SliderComponentShape {
  final double radius;
  const _CustomPaceThumbShape({this.radius = 13.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
    canvas.drawCircle(center + const Offset(0, 2), radius, shadowPaint);

    // White circle
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Border
    final strokePaint = Paint()
      ..color = const Color(0xFFE2E4E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius, strokePaint);
  }
}

/// Sloth hanging from branch vector painter (Cal AI 1:1)
class _SlothPainter extends CustomPainter {
  final Color color;
  _SlothPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. Branch line across top (viewBox 0 0 70 50)
    final branchPath = Path()
      ..moveTo(w * (8 / 70), h * (13.5 / 50))
      ..lineTo(w * (62 / 70), h * (13.5 / 50))
      ..lineTo(w * (62 / 70), h * (17 / 50))
      ..lineTo(w * (8 / 70), h * (17 / 50))
      ..close();
    canvas.drawPath(branchPath, paint);

    // 2. Claws/Arms hooked on branch
    canvas.drawPath(
      Path()
        ..moveTo(w * (20 / 70), h * (17 / 50))
        ..cubicTo(w * (20 / 70), h * (10 / 50), w * (24 / 70), h * (10 / 50), w * (24 / 70), h * (17 / 50)),
      strokePaint..strokeWidth = w * (3 / 70),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * (33 / 70), h * (17 / 50))
        ..cubicTo(w * (33 / 70), h * (9 / 50), w * (38 / 70), h * (9 / 50), w * (38 / 70), h * (17 / 50)),
      strokePaint..strokeWidth = w * (3.2 / 70),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * (44 / 70), h * (17 / 50))
        ..cubicTo(w * (44 / 70), h * (10 / 50), w * (48 / 70), h * (10 / 50), w * (48 / 70), h * (17 / 50)),
      strokePaint..strokeWidth = w * (3 / 70),
    );

    // 3. Hanging Sloth curved body
    final body = Path()
      ..moveTo(w * (19 / 70), h * (16 / 50))
      ..cubicTo(w * (15 / 70), h * (22 / 50), w * (17 / 70), h * (33 / 50), w * (24 / 70), h * (38 / 50))
      ..cubicTo(w * (31 / 70), h * (43 / 50), w * (45 / 70), h * (42 / 50), w * (51 / 70), h * (35 / 50))
      ..cubicTo(w * (56 / 70), h * (30 / 50), w * (56 / 70), h * (20 / 50), w * (51 / 70), h * (15 / 50))
      ..cubicTo(w * (48 / 70), h * (11 / 50), w * (44 / 70), h * (13 / 50), w * (44 / 70), h * (17 / 50))
      ..cubicTo(w * (44 / 70), h * (24 / 50), w * (38 / 70), h * (27 / 50), w * (33 / 70), h * (24 / 50))
      ..cubicTo(w * (30 / 70), h * (22 / 50), w * (30 / 70), h * (16 / 50), w * (30 / 70), h * (16 / 50))
      ..cubicTo(w * (26 / 70), h * (16 / 50), w * (23 / 70), h * (20 / 50), w * (21 / 70), h * (22 / 50))
      ..cubicTo(w * (19 / 70), h * (19 / 50), w * (21 / 70), h * (16 / 50), w * (19 / 70), h * (16 / 50))
      ..close();
    canvas.drawPath(body, paint);

    // 4. Sloth Face base
    canvas.drawCircle(Offset(w * (51.5 / 70), h * (27.5 / 50)), h * (8 / 50), paint);

    // 5. Light Face Mask
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * (50 / 70), h * (28 / 50)),
        width: w * (11.6 / 70),
        height: h * (9.6 / 50),
      ),
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );

    // 6. Eye Mask Patches
    final leftPatch = Path()
      ..moveTo(w * (46 / 70), h * (27 / 50))
      ..cubicTo(w * (47 / 70), h * (25.5 / 50), w * (49.5 / 70), h * (26.5 / 50), w * (48.5 / 70), h * (28.5 / 50))
      ..cubicTo(w * (47.5 / 70), h * (29.5 / 50), w * (45.5 / 70), h * (28.5 / 50), w * (46 / 70), h * (27 / 50))
      ..close();
    canvas.drawPath(leftPatch, paint);

    final rightPatch = Path()
      ..moveTo(w * (52 / 70), h * (27 / 50))
      ..cubicTo(w * (53 / 70), h * (25.5 / 50), w * (55.5 / 70), h * (26.5 / 50), w * (54.5 / 70), h * (28.5 / 50))
      ..cubicTo(w * (53.5 / 70), h * (29.5 / 50), w * (51.5 / 70), h * (28.5 / 50), w * (52 / 70), h * (27 / 50))
      ..close();
    canvas.drawPath(rightPatch, paint);

    // 7. Eye White Dots
    canvas.drawCircle(Offset(w * (47.2 / 70), h * (27.6 / 50)), h * (0.65 / 50), Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * (53.2 / 70), h * (27.6 / 50)), h * (0.65 / 50), Paint()..color = Colors.white);

    // 8. Nose
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * (49.8 / 70), h * (30 / 50)),
        width: w * (2.2 / 70),
        height: h * (1.4 / 50),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SlothPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Sitting Rabbit vector silhouette painter (Cal AI 1:1, facing right)
class _RabbitPainter extends CustomPainter {
  final Color color;
  _RabbitPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final backEarPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    // 1. Back Ear
    final backEar = Path()
      ..moveTo(w * (38 / 70), h * (17 / 50))
      ..cubicTo(w * (36 / 70), h * (8 / 50), w * (30 / 70), h * (3 / 50), w * (27 / 70), h * (4.5 / 50))
      ..cubicTo(w * (25 / 70), h * (6.5 / 50), w * (29 / 70), h * (14 / 50), w * (34 / 70), h * (18 / 50))
      ..close();
    canvas.drawPath(backEar, backEarPaint);

    // 2. Front Ear
    final frontEar = Path()
      ..moveTo(w * (43 / 70), h * (18 / 50))
      ..cubicTo(w * (44 / 70), h * (9 / 50), w * (39 / 70), h * (3 / 50), w * (35 / 70), h * (4 / 50))
      ..cubicTo(w * (32 / 70), h * (5 / 50), w * (34 / 70), h * (13 / 50), w * (39 / 70), h * (19 / 50))
      ..close();
    canvas.drawPath(frontEar, paint);

    // Inner ear subtle highlight
    final innerEar = Path()
      ..moveTo(w * (41.5 / 70), h * (16 / 50))
      ..cubicTo(w * (42 / 70), h * (10.5 / 50), w * (38.5 / 70), h * (6 / 50), w * (36 / 70), h * (6.5 / 50))
      ..cubicTo(w * (34.5 / 70), h * (7.2 / 50), w * (36.5 / 70), h * (12.5 / 50), w * (39 / 70), h * (17 / 50))
      ..close();
    canvas.drawPath(innerEar, highlightPaint);

    // 3. Fluffy Tail
    canvas.drawCircle(Offset(w * (17 / 70), h * (33 / 50)), h * (4.5 / 50), paint);

    // 4. Sitting Bunny Body & Head Silhouette (Facing right)
    final body = Path()
      ..moveTo(w * (43 / 70), h * (16 / 50))
      ..cubicTo(w * (38 / 70), h * (17 / 50), w * (37 / 70), h * (21 / 50), w * (38 / 70), h * (25 / 50))
      ..cubicTo(w * (35 / 70), h * (25 / 50), w * (28 / 70), h * (26 / 50), w * (23 / 70), h * (30 / 50))
      ..cubicTo(w * (18 / 70), h * (34 / 50), w * (18 / 70), h * (40 / 50), w * (22 / 70), h * (43 / 50))
      ..cubicTo(w * (26 / 70), h * (44 / 50), w * (32 / 70), h * (44 / 50), w * (35 / 70), h * (44 / 50))
      ..cubicTo(w * (38 / 70), h * (44 / 50), w * (38 / 70), h * (40 / 50), w * (36 / 70), h * (38 / 50))
      ..cubicTo(w * (34 / 70), h * (35 / 50), w * (33 / 70), h * (33 / 50), w * (36 / 70), h * (32 / 50))
      ..cubicTo(w * (40 / 70), h * (31 / 50), w * (43 / 70), h * (34 / 50), w * (44 / 70), h * (38 / 50))
      ..cubicTo(w * (45 / 70), h * (41 / 50), w * (45 / 70), h * (44 / 50), w * (49 / 70), h * (44 / 50))
      ..cubicTo(w * (52 / 70), h * (44 / 50), w * (52 / 70), h * (40 / 50), w * (50 / 70), h * (36 / 50))
      ..cubicTo(w * (49 / 70), h * (31 / 50), w * (49 / 70), h * (26 / 50), w * (49 / 70), h * (25 / 50))
      ..cubicTo(w * (53 / 70), h * (25 / 50), w * (54 / 70), h * (23 / 50), w * (53 / 70), h * (21 / 50))
      ..cubicTo(w * (52 / 70), h * (18 / 50), w * (48 / 70), h * (15 / 50), w * (43 / 70), h * (16 / 50))
      ..close();
    canvas.drawPath(body, paint);

    // 5. Paws
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * (47 / 70), h * (42 / 50)),
        width: w * (7 / 70),
        height: h * (4 / 50),
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * (27 / 70), h * (42.5 / 50)),
        width: w * (13 / 70),
        height: h * (4 / 50),
      ),
      paint,
    );

    // 6. Eye dot
    canvas.drawCircle(
      Offset(w * (47 / 70), h * (20.5 / 50)),
      h * (1.3 / 50),
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(w * (46.7 / 70), h * (20.2 / 50)),
      h * (0.6 / 50),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RabbitPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Sprinting Cheetah with motion lines (Cal AI 1:1)
class _CheetahPainter extends CustomPainter {
  final Color color;
  _CheetahPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * (2.2 / 70)
      ..strokeCap = StrokeCap.round;

    // 1. 4 Speed Lines (viewBox 0 0 70 50)
    canvas.drawLine(Offset(w * (42 / 70), h * (10 / 50)), Offset(w * (52 / 70), h * (10 / 50)), linePaint);
    canvas.drawLine(Offset(w * (45 / 70), h * (14 / 50)), Offset(w * (55 / 70), h * (14 / 50)), linePaint);
    canvas.drawLine(Offset(w * (12 / 70), h * (18 / 50)), Offset(w * (23 / 70), h * (18 / 50)), linePaint);
    canvas.drawLine(Offset(w * (14 / 70), h * (22 / 50)), Offset(w * (20 / 70), h * (22 / 50)), linePaint);

    // 2. Cheetah Body Silhouette with Eye Cutout (evenodd)
    final bodyPath = Path()
      ..fillType = PathFillType.evenOdd
      // Outer Cheetah silhouette
      ..moveTo(w * (11 / 70), h * (31 / 50))
      ..cubicTo(w * (8 / 70), h * (29 / 50), w * (10 / 70), h * (27 / 50), w * (15 / 70), h * (28 / 50))
      ..cubicTo(w * (18 / 70), h * (29 / 50), w * (22 / 70), h * (30 / 50), w * (26 / 70), h * (30 / 50))
      ..cubicTo(w * (33 / 70), h * (30 / 50), w * (44 / 70), h * (24 / 50), w * (50 / 70), h * (24 / 50))
      ..cubicTo(w * (54 / 70), h * (24 / 50), w * (57 / 70), h * (26 / 50), w * (59 / 70), h * (28 / 50))
      ..cubicTo(w * (60 / 70), h * (31 / 50), w * (57 / 70), h * (33 / 50), w * (55 / 70), h * (32 / 50))
      ..cubicTo(w * (56 / 70), h * (34 / 50), w * (62 / 70), h * (39 / 50), w * (60.5 / 70), h * (41 / 50))
      ..cubicTo(w * (58 / 70), h * (42 / 50), w * (54 / 70), h * (39 / 50), w * (52 / 70), h * (36 / 50))
      ..cubicTo(w * (49 / 70), h * (34 / 50), w * (46 / 70), h * (34 / 50), w * (43 / 70), h * (35 / 50))
      ..cubicTo(w * (39 / 70), h * (36 / 50), w * (34 / 70), h * (40 / 50), w * (28 / 70), h * (45 / 50))
      ..cubicTo(w * (26 / 70), h * (45 / 50), w * (24 / 70), h * (44 / 50), w * (25 / 70), h * (41 / 50))
      ..cubicTo(w * (27 / 70), h * (37 / 50), w * (29 / 70), h * (34 / 50), w * (26 / 70), h * (33 / 50))
      ..cubicTo(w * (21 / 70), h * (32 / 50), w * (15 / 70), h * (32 / 50), w * (11 / 70), h * (31 / 50))
      ..close()
      // Eye cutout
      ..addOval(
        Rect.fromCircle(
          center: Offset(w * (52.5 / 70), h * (29.1 / 50)),
          radius: h * (1.1 / 50),
        ),
      );
    canvas.drawPath(bodyPath, paint);

    // 3. Front Leg Stride
    final frontLeg = Path()
      ..moveTo(w * (50 / 70), h * (29 / 50))
      ..lineTo(w * (62 / 70), h * (37 / 50))
      ..cubicTo(w * (63 / 70), h * (38 / 50), w * (62 / 70), h * (40 / 50), w * (60 / 70), h * (39 / 50))
      ..lineTo(w * (48 / 70), h * (32 / 50))
      ..close();
    canvas.drawPath(frontLeg, paint);

    // 4. Back Hind Leg Stride
    final hindLeg = Path()
      ..moveTo(w * (21 / 70), h * (31 / 50))
      ..lineTo(w * (7 / 70), h * (40 / 50))
      ..cubicTo(w * (6 / 70), h * (41 / 50), w * (5 / 70), h * (40 / 50), w * (6 / 70), h * (38 / 50))
      ..lineTo(w * (18 / 70), h * (30 / 50))
      ..close();
    canvas.drawPath(hindLeg, paint);

    // 5. Ear Tip
    final ear = Path()
      ..moveTo(w * (52 / 70), h * (24 / 50))
      ..cubicTo(w * (52 / 70), h * (21 / 50), w * (55 / 70), h * (21 / 50), w * (55 / 70), h * (24 / 50))
      ..close();
    canvas.drawPath(ear, paint);
  }

  @override
  bool shouldRepaint(covariant _CheetahPainter oldDelegate) =>
      oldDelegate.color != color;
}
