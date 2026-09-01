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
            children: [
              Text(
                'KHẨU PHẦN HÔM NAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textMuted,
                  letterSpacing: 1.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(clampedPct * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$caloriesLeft',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -1.8,
                  height: 0.95,
                ),
              ),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  s.caloriesLeft,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: clampedPct,
              backgroundColor: isDark
                  ? const Color(0xFF34313B)
                  : const Color(0xFFE8E8EA),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF15A3A)),
            ),
          ),
          if (caloriesBurned > 0) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: burnedBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 17,
                    color: Color(0xFFF15A3A),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '+$caloriesBurned đã đốt',
                    style: const TextStyle(
                      color: Color(0xFFE55233),
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
                  label: 'ĐÃ ĂN',
                  value: caloriesConsumed,
                  textColor: textDark,
                  mutedColor: textMuted,
                ),
              ),
              Expanded(
                child: _CalorieMetric(
                  label: 'ĐÃ ĐỐT',
                  value: caloriesBurned,
                  textColor: textDark,
                  mutedColor: textMuted,
                ),
              ),
              Expanded(
                child: _CalorieMetric(
                  label: 'MỤC TIÊU',
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
