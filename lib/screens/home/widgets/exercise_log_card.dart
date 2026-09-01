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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
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
            // Exercise Icon Box matching meal thumbnail size
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2935) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _exerciseIcon(entry.activityType, entry.source),
                size: 26,
                color: isDark ? Colors.white : const Color(0xFF1E1B26),
              ),
            ),
            const SizedBox(width: 14),

            // Exercise Title, Time, and Calorie / Duration info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _exerciseTitle(entry.activityType, entry.source),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2A34)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 15,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.caloriesBurned.round()} calo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      if (entry.durationMinutes != null &&
                          entry.durationMinutes! > 0) ...[
                        Text(
                          '  ·  ${entry.durationMinutes} phút',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
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
