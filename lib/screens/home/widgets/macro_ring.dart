import 'dart:math';
import 'package:flutter/material.dart';

class MacroRing extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;

  const MacroRing({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    this.unit = 'g',
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (target > 0 ? value / target : 0.0).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(48, 48),
                painter: _MacroRingPainter(
                  progress: progress,
                  color: color,
                  trackColor: const Color(0xFFF0F1F3),
                ),
              ),
              Text(
                '${value.round()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '$pct% / ${target.round()}$unit',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9A9AA1),
          ),
        ),
      ],
    );
  }
}

class _MacroRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _MacroRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 5) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
