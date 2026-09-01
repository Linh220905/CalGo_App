import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';

class CalAiHeroCard extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesBurned;
  final int caloriesLeft;
  final int targetCalories;
  final double progress;

  const CalAiHeroCard({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.caloriesLeft,
    required this.targetCalories,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;
    final clampedPct = progress.clamp(0.0, 1.0);

    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2A34)
        : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF8E8D9A)
        : const Color(0xFF64748B);
    const ringColor = Color(0xFFF15A3A);
    final ringTrackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final burnedBg = isDark ? const Color(0xFF3A241A) : const Color(0xFFFFEFE6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x0A0F172A),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left column: Calories Left & Target Fraction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$caloriesLeft',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: -1.5,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.caloriesLeft,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$caloriesConsumed',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          TextSpan(
                            text: ' / $targetCalories kcal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right column: Circular Calorie Progress Ring with Flame icon 🔥
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(84, 84),
                      painter: _CalorieHeroRingPainter(
                        progress: clampedPct,
                        color: ringColor,
                        trackColor: ringTrackColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 24,
                          color: Color(0xFFF15A3A),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(clampedPct * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (caloriesBurned > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: burnedBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: Color(0xFFF15A3A),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.burnedCaloriesPill(caloriesBurned),
                    style: const TextStyle(
                      color: Color(0xFFE55233),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CalorieMetric(
                  label: s.consumedLabelUpper,
                  value: caloriesConsumed,
                  textColor: textDark,
                  mutedColor: textMuted,
                ),
              ),
              Expanded(
                child: _CalorieMetric(
                  label: s.burnedLabelUpper,
                  value: caloriesBurned,
                  textColor: textDark,
                  mutedColor: textMuted,
                ),
              ),
              Expanded(
                child: _CalorieMetric(
                  label: s.targetLabelUpper,
                  value: targetCalories,
                  textColor: textDark,
                  mutedColor: textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalorieHeroRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _CalorieHeroRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 12) / 2;

    // Track background
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0,
    );

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CalorieHeroRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

class _CalorieMetric extends StatelessWidget {
  final String label;
  final int value;
  final Color textColor;
  final Color mutedColor;

  const _CalorieMetric({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: mutedColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
