import 'dart:math';
import 'package:flutter/material.dart';

class CalorieRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final Color? trackColor;
  final String? centerLabel;
  final bool showGlow;

  const CalorieRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.color = const Color(0xFF111111),
    this.trackColor,
    this.centerLabel,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutExpo,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            if (showGlow)
              Container(
                width: size * 0.86,
                height: size * 0.86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.22 * value.clamp(0, 1)),
                      blurRadius: size * 0.18,
                      spreadRadius: size * 0.01,
                    ),
                  ],
                ),
              ),
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: value,
                color: color,
                trackColor: trackColor ?? const Color(0xFFEFEFF1),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).toInt()}',
                  style: TextStyle(
                    fontSize: size * 0.24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A0A0A),
                    letterSpacing: -1,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (centerLabel != null) ...[
                  SizedBox(height: size * 0.02),
                  Text(
                    centerLabel!,
                    style: TextStyle(
                      fontSize: size * 0.09,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA0A0A6),
                      letterSpacing: 0.2,
                    ),
                  ),
                ] else
                  Text(
                    '%',
                    style: TextStyle(
                      fontSize: size * 0.11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 9;

    // Track
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    final sweep = 2 * pi * progress;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Gradient arc — deepens toward the leading edge for a subtle sense of motion
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: const GradientRotation(-pi / 2),
      colors: [
        color.withOpacity(0.55),
        color,
      ],
      stops: const [0, 1],
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );

    // Small bright dot at the leading tip — reads like a "live" indicator
    if (progress < 1) {
      final tipAngle = -pi / 2 + sweep;
      final tip = Offset(c.dx + r * cos(tipAngle), c.dy + r * sin(tipAngle));
      canvas.drawCircle(tip, 5.5, Paint()..color = color);
      canvas.drawCircle(
          tip,
          5.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
