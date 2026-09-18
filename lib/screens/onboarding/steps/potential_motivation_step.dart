import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';

class PotentialMotivationStep extends StatelessWidget {
  const PotentialMotivationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final isDark = context.watch<AppSettingsProvider>().isDarkMode;

    final bgColor = isDark ? const Color(0xFF131217) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111111);
    final cardBg = isDark ? const Color(0xFF1C1A24) : const Color(0xFFF9F9FA);
    final cardBorder = isDark ? const Color(0xFF2A2836) : const Color(0xFFEFEFF2);
    final mutedText = isDark ? const Color(0xFF9E9DA8) : const Color(0xFF555555);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Top Title
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 500)),
                  SlideEffect(
                    begin: Offset(0, -0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 500),
                  ),
                ],
                child: Text(
                  s.potentialMotivationTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Middle Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 150),
                      ),
                      SlideEffect(
                        begin: Offset(0, 0.05),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 150),
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
                            s.weightTransitionTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Graph
                          SizedBox(
                            height: 170,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _WeightTransitionGraphPainter(
                                isDark: isDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // X-Axis Labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  s.days3,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Text(
                                s.days7,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  s.days30,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Bottom Note
                          Text(
                            s.weightTransitionDesc,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: mutedText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
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
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      s.continueLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

class _WeightTransitionGraphPainter extends CustomPainter {
  final bool isDark;

  _WeightTransitionGraphPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grid line paint (dashed)
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF333140) : const Color(0xFFE2E2E8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Bottom solid axis line
    final axisPaint = Paint()
      ..color = isDark ? const Color(0xFF3F3D4D) : const Color(0xFF222226)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal dashed lines
    _drawDashedHorizontal(canvas, 0, w, h * 0.45, gridPaint);
    _drawDashedHorizontal(canvas, 0, w, h * 0.78, gridPaint);

    // Draw right vertical dashed line
    _drawDashedVertical(canvas, w - 10, 0, h, gridPaint);

    // Draw bottom solid line
    canvas.drawLine(Offset(0, h), Offset(w, h), axisPaint);

    // Points on the curve
    final p0 = Offset(10, h * 0.78);
    final p1 = Offset(w * 0.32, h * 0.75);
    final p2 = Offset(w * 0.60, h * 0.60);
    final p3 = Offset(w - 12, h * 0.20);

    // Build smooth cubic bezier curve
    final path = Path();
    path.moveTo(p0.dx, p0.dy);

    // Smooth control points to achieve S-curve transition
    path.cubicTo(
      w * 0.15,
      h * 0.78,
      w * 0.22,
      h * 0.76,
      p1.dx,
      p1.dy,
    );
    path.cubicTo(
      w * 0.42,
      h * 0.74,
      w * 0.50,
      h * 0.65,
      p2.dx,
      p2.dy,
    );
    path.cubicTo(
      w * 0.72,
      h * 0.52,
      w * 0.85,
      h * 0.22,
      p3.dx,
      p3.dy,
    );

    // Area fill under curve with warm gradient
    final fillPath = Path.from(path)
      ..lineTo(p3.dx, h)
      ..lineTo(p0.dx, h)
      ..close();

    final gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, p3.dy),
        Offset(0, h),
        [
          (isDark ? const Color(0xFFC2704E) : const Color(0xFFDE9670)).withValues(alpha: 0.38),
          (isDark ? const Color(0xFFC2704E) : const Color(0xFFF7ECE4)).withValues(alpha: 0.05),
        ],
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, gradientPaint);

    // Draw curve line
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFFE58860) : const Color(0xFFB56B48)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw circle points (p0, p1, p2)
    final circlePoints = [p0, p1, p2];
    final circleFill = Paint()
      ..color = isDark ? const Color(0xFF1C1A24) : Colors.white
      ..style = PaintingStyle.fill;

    final circleStroke = Paint()
      ..color = isDark ? const Color(0xFFE58860) : const Color(0xFF222226)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (final pt in circlePoints) {
      canvas.drawCircle(pt, 5.5, circleFill);
      canvas.drawCircle(pt, 5.5, circleStroke);
    }

    // Draw Trophy Badge at p3
    final trophyCenter = Offset(p3.dx - 2, p3.dy - 6);
    const badgeRadius = 14.0;

    final badgePaint = Paint()
      ..color = const Color(0xFFD47C50)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(trophyCenter, badgeRadius, badgePaint);

    // Draw Trophy icon inside badge
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.emoji_events_rounded.codePoint),
        style: TextStyle(
          fontSize: 16,
          fontFamily: Icons.emoji_events_rounded.fontFamily,
          package: Icons.emoji_events_rounded.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        trophyCenter.dx - iconPainter.width / 2,
        trophyCenter.dy - iconPainter.height / 2,
      ),
    );
  }

  void _drawDashedHorizontal(
    Canvas canvas,
    double x1,
    double x2,
    double y,
    Paint paint,
  ) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = x1;
    while (startX < x2) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  void _drawDashedVertical(
    Canvas canvas,
    double x,
    double y1,
    double y2,
    Paint paint,
  ) {
    const dashHeight = 3.0;
    const dashSpace = 3.0;
    double startY = y1;
    while (startY < y2) {
      canvas.drawLine(Offset(x, startY), Offset(x, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _WeightTransitionGraphPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
