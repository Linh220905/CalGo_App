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
    final ringProgressColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final ringTrackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x060F172A),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.caloriesLeft,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$caloriesConsumed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          TextSpan(
                            text: ' / $targetCalories kcal',
                            style: TextStyle(
                              fontSize: 14,
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

              // Right column: Circular Gauge with inner flame badge
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(92, 92),
                      painter: _CalorieHeroRingPainter(
                        progress: clampedPct,
                        color: ringProgressColor,
                        trackColor: ringTrackColor,
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF332014)
                            : const Color(0xFFFFF4ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          size: 26,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Optional Burned Calories Orange Pill (as requested by user)
          if (caloriesBurned > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF332014)
                    : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF522B14)
                      : const Color(0xFFFFEDD5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 15,
                    color: Color(0xFFF97316),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.burnedCaloriesPill(caloriesBurned),
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFFF9D5C)
                          : const Color(0xFFC2410C),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
