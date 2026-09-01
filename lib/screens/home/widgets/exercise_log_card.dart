import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/exercise_entry.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../utils/localized_date_utils.dart';
import '../../../widgets/swipeable_card.dart';

class ExerciseLogCard extends StatelessWidget {
  final ExerciseEntry entry;

  const ExerciseLogCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final timeStr = localizedTime(entry.occurredAt, settings.languageCode);

    return SwipeableCard(
      confirmMessage: 'Bạn có chắc chắn muốn xóa bài tập này?',
      onDelete: () async {
        try {
          await context.read<HomeProvider>().removeExerciseEntry(entry.id);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xóa bài tập thất bại. Vui lòng thử lại.')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x0A0F172A),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Exercise Icon Square Box
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2935) : const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _exerciseIcon(entry.activityType, entry.source),
                size: 32,
                color: isDark ? Colors.white : const Color(0xFF1E1B26),
              ),
            ),
            const SizedBox(width: 16),

            // Exercise Title, Time, and Calorie / Duration info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _exerciseTitle(entry.activityType, entry.source),
                        style: TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${entry.caloriesBurned.round()}',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'calo',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.durationMinutes != null && entry.durationMinutes! > 0) ...[
                        Text(
                          '  ·  ${entry.durationMinutes}′',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _exerciseIcon(String activityType, String source) {
    if (source == 'health') return Icons.favorite_rounded;
    return switch (activityType) {
      'running' => Icons.directions_run_rounded,
      'walking' => Icons.directions_walk_rounded,
      'cycling' => Icons.directions_bike_rounded,
      'swimming' => Icons.pool_rounded,
      'workout' => Icons.fitness_center_rounded,
      _ => Icons.local_fire_department_rounded,
    };
  }

  static String _exerciseTitle(String activityType, String source) {
    if (source == 'health') return 'Đồng bộ Apple Health';
    return switch (activityType) {
      'running' => 'Chạy bộ',
      'walking' => 'Đi bộ',
      'cycling' => 'Đạp xe',
      'swimming' => 'Bơi lội',
      'workout' => 'Tập luyện',
      'manual' => 'Ghi thủ công',
      _ => 'Tập luyện',
    };
  }
}
