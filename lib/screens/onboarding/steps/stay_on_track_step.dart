import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';

class StayOnTrackStep extends StatefulWidget {
  const StayOnTrackStep({super.key});

  @override
  State<StayOnTrackStep> createState() => _StayOnTrackStepState();
}

class _StayOnTrackStepState extends State<StayOnTrackStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _curveAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final isDark = context.watch<AppSettingsProvider>().isDarkMode;
    final provider = context.watch<OnboardingProvider>();
    final goal = provider.data.goalType ?? GoalType.lose;

    final bgColor = isDark ? const Color(0xFF131217) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final cardBg = isDark ? const Color(0xFF1C1A24) : const Color(0xFFF9F9FA);
    final cardBorder =
        isDark ? const Color(0xFF2A2836) : const Color(0xFFEFEFF2);
    final mutedText =
        isDark ? const Color(0xFF9E9DA8) : const Color(0xFF555555);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header Title
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 400)),
                  SlideEffect(
                    begin: Offset(0, -0.05),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 400),
                  ),
                ],
                child: Text(
                  s.stayOnTrackTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.18,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Main Trend Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        duration: Duration(milliseconds: 500),
                        delay: Duration(milliseconds: 100),
                      ),
                      SlideEffect(
                        begin: Offset(0, 0.04),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 500),
                        delay: Duration(milliseconds: 100),
                      ),
                    ],
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cardBorder, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.weightTrendTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Graph Canvas
                          SizedBox(
                            height: 190,
                            width: double.infinity,
                            child: AnimatedBuilder(
                              animation: _curveAnimation,
                              builder: (context, _) {
                                return CustomPaint(
                                  painter: _WeightTrendGraphPainter(
                                    progress: _curveAnimation.value,
                                    goal: goal,
                                    isDark: isDark,
                                    withoutPlanLabel: s.withoutPlanLabel,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),

                          // X-Axis Month Labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.month1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: mutedText,
                                ),
                              ),
                              Text(
                                s.month6,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: mutedText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Bottom description text
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                s.stayOnTrackDesc,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: mutedText,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom CTA Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () async {
                      final provider = context.read<OnboardingProvider>();
                      await provider.nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF141416),
                      foregroundColor: isDark ? const Color(0xFF141416) : Colors.white,
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
      ),
    );
  }
}

class _WeightTrendGraphPainter extends CustomPainter {
  final double progress;
  final GoalType goal;
  final bool isDark;
  final String withoutPlanLabel;

  _WeightTrendGraphPainter({
    required this.progress,
    required this.goal,
    required this.isDark,
    required this.withoutPlanLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF333140) : const Color(0xFFE2E2E8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = isDark ? const Color(0xFF4A4858) : const Color(0xFFD4D4D8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw horizontal dashed grid lines
    _drawDashedHorizontal(canvas, 10, w - 10, h * 0.28, gridPaint);
    _drawDashedHorizontal(canvas, 10, w - 10, h * 0.60, gridPaint);

    // Draw bottom solid baseline
    canvas.drawLine(Offset(10, h * 0.90), Offset(w - 10, h * 0.90), axisPaint);

    // Coordinate curves based on GoalType
    final (blackPathFull, redPathFull, startPt, endPt) = _generatePaths(w, h);

    // Trim paths by progress animation
    final redPath = _extractSubPath(redPathFull, progress);
    final blackPath = _extractSubPath(blackPathFull, progress);

    // Area fill under black curve (CalGo track)
    if (progress > 0.05) {
      final fillPath = Path.from(blackPath)
        ..lineTo(w * progress.clamp(0.05, 0.92), h * 0.90)
        ..lineTo(startPt.dx, h * 0.90)
        ..close();

      final blackFillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, startPt.dy),
          Offset(0, h * 0.90),
          [
            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.01),
          ],
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, blackFillPaint);
    }

    // Area fill under red curve (Without a plan)
    if (progress > 0.05) {
      final redFillPath = Path.from(redPath)
        ..lineTo(w * progress.clamp(0.05, 0.92), h * 0.90)
        ..lineTo(startPt.dx, h * 0.90)
        ..close();

      final redFillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, h * 0.15),
          Offset(0, h * 0.90),
          [
            const Color(0xFFEF4444).withValues(alpha: 0.12),
            const Color(0xFFEF4444).withValues(alpha: 0.01),
          ],
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(redFillPath, redFillPaint);
    }

    // Draw Red Curve (Without a plan)
    final redLinePaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.85)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(redPath, redLinePaint);

    // Draw Black Curve (CalGo with a plan)
    final blackLinePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(blackPath, blackLinePaint);

    // Draw Starting Point Circle
    final circleFill = Paint()
      ..color = isDark ? const Color(0xFF1C1A24) : Colors.white
      ..style = PaintingStyle.fill;

    final circleStroke = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF111111)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(startPt, 6, circleFill);
    canvas.drawCircle(startPt, 6, circleStroke);

    // Draw End Point Circle when progress near 1.0
    if (progress > 0.90) {
      final endAlpha = ((progress - 0.90) / 0.10).clamp(0.0, 1.0);
      final endCircleStroke = Paint()
        ..color = (isDark ? Colors.white : const Color(0xFF111111))
            .withValues(alpha: endAlpha)
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(endPt, 6, circleFill);
      canvas.drawCircle(endPt, 6, endCircleStroke);
    }

    // Draw "Without a plan" text tag on red curve
    if (progress > 0.70) {
      _drawWithoutPlanTag(canvas, w, h);
    }
  }

  (Path, Path, Offset, Offset) _generatePaths(double w, double h) {
    final startPt = switch (goal) {
      GoalType.lose => Offset(18, h * 0.28),
      GoalType.gain => Offset(18, h * 0.75),
      GoalType.maintain => Offset(18, h * 0.50),
    };

    final endPt = switch (goal) {
      GoalType.lose => Offset(w - 22, h * 0.88),
      GoalType.gain => Offset(w - 22, h * 0.18),
      GoalType.maintain => Offset(w - 22, h * 0.50),
    };

    final blackPath = Path()..moveTo(startPt.dx, startPt.dy);
    final redPath = Path()..moveTo(startPt.dx, startPt.dy);

    switch (goal) {
      case GoalType.lose:
        // CalGo: Starts high, smooth descent to low weight
        blackPath.cubicTo(
          w * 0.35,
          h * 0.30,
          w * 0.55,
          h * 0.75,
          endPt.dx,
          endPt.dy,
        );

        // Without Plan: Drops too quick at first, then rebounds high (Yo-yo)
        redPath.cubicTo(
          w * 0.28,
          h * 0.35,
          w * 0.38,
          h * 0.78,
          w * 0.50,
          h * 0.60,
        );
        redPath.cubicTo(
          w * 0.62,
          h * 0.42,
          w * 0.78,
          h * 0.16,
          w - 22,
          h * 0.16,
        );
        break;

      case GoalType.gain:
        // CalGo: Starts low, smooth healthy ascent to target weight/muscle
        blackPath.cubicTo(
          w * 0.35,
          h * 0.72,
          w * 0.55,
          h * 0.28,
          endPt.dx,
          endPt.dy,
        );

        // Without Plan: Fluctuates low, drops down
        redPath.cubicTo(
          w * 0.28,
          h * 0.68,
          w * 0.38,
          h * 0.45,
          w * 0.50,
          h * 0.58,
        );
        redPath.cubicTo(
          w * 0.65,
          h * 0.75,
          w * 0.80,
          h * 0.88,
          w - 22,
          h * 0.88,
        );
        break;

      case GoalType.maintain:
        // CalGo: Perfect steady consistent horizontal line
        blackPath.cubicTo(
          w * 0.35,
          h * 0.50,
          w * 0.65,
          h * 0.50,
          endPt.dx,
          endPt.dy,
        );

        // Without Plan: Unstable up-and-down oscillation
        redPath.cubicTo(
          w * 0.25,
          h * 0.22,
          w * 0.45,
          h * 0.78,
          w * 0.65,
          h * 0.25,
        );
        redPath.cubicTo(
          w * 0.80,
          h * 0.70,
          w * 0.90,
          h * 0.35,
          w - 22,
          h * 0.65,
        );
        break;
    }

    return (blackPath, redPath, startPt, endPt);
  }

  Path _extractSubPath(Path path, double factor) {
    if (factor <= 0) return Path();
    if (factor >= 1.0) return path;

    final subPath = Path();
    for (final metric in path.computeMetrics()) {
      final extractLength = metric.length * factor;
      subPath.addPath(
        metric.extractPath(0, extractLength),
        Offset.zero,
      );
    }
    return subPath;
  }

  void _drawWithoutPlanTag(Canvas canvas, double w, double h) {
    final tagOffset = switch (goal) {
      GoalType.lose => Offset(w * 0.64, h * 0.45),
      GoalType.gain => Offset(w * 0.64, h * 0.72),
      GoalType.maintain => Offset(w * 0.60, h * 0.32),
    };

    final textPainter = TextPainter(
      text: TextSpan(
        text: withoutPlanLabel,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFEF4444),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, tagOffset);
  }

  void _drawDashedHorizontal(
    Canvas canvas,
    double x1,
    double x2,
    double y,
    Paint paint,
  ) {
    const dashWidth = 3.5;
    const dashSpace = 3.5;
    double startX = x1;
    while (startX < x2) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _WeightTrendGraphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.goal != goal ||
        oldDelegate.isDark != isDark;
  }
}
