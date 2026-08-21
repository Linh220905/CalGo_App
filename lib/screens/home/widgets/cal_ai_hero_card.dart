import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';

class CalAiHeroCard extends StatelessWidget {
  final int caloriesConsumed;
  final int caloriesLeft;
  final int targetCalories;
  final double progress;

  const CalAiHeroCard({
    super.key,
    required this.caloriesConsumed,
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
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final ringColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final ringTrackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Con số Calo bên trái
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$caloriesLeft',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.caloriesLeft,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 6),
              // "consumed / target kcal" fraction
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
                        fontWeight: FontWeight.w400,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Vòng tròn tiến độ bên phải với icon Ngọn Lửa 🔥
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(88, 88),
                  painter: _CalorieHeroRingPainter(
                    progress: clampedPct,
                    color: ringColor,
                    trackColor: ringTrackColor,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF332014)
                        : const Color(0xFFFFEDD5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 24,
                    color: Color(0xFFF97316),
                  ),
                ),
              ],
            ),
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
