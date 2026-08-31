import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/history_item.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../utils/nutrition_calculator.dart';
import '../../../utils/localized_date_utils.dart';

class DayGroupData {
  final int date;
  final String fullDate;
  final List<HistoryItem> items;
  final bool isToday;

  DayGroupData({
    required this.date,
    required this.fullDate,
    required this.items,
    required this.isToday,
  });
}

class MonthCalendarGrid extends StatelessWidget {
  final String monthLabel;
  final int totalMeals;
  final int year;
  final int month;
  final List<DayGroupData> days;
  final Function(DayGroupData day) onSelectDay;
  final VoidCallback onSelectTodayEmpty;
  final bool isDark;
  final Color cardColor;
  final Color subtitleColor;
  final Color primaryTextColor;
  final Color borderColor;

  const MonthCalendarGrid({
    super.key,
    required this.monthLabel,
    required this.totalMeals,
    required this.year,
    required this.month,
    required this.days,
    required this.onSelectDay,
    required this.onSelectTodayEmpty,
    required this.isDark,
    required this.cardColor,
    required this.subtitleColor,
    required this.primaryTextColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    final weekdays = localizedWeekdays(
      context.read<AppSettingsProvider>().languageCode,
    );
    final daysCount = DateTime(year, month + 1, 0).day;
    final firstDayOfWeek = DateTime(year, month, 1).weekday % 7; // 0=Sun

    final emptyDayColor =
        isDark ? const Color(0xFF212027) : const Color(0xFFF1F3F2);
    final hasMealBg =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    const accentColor = Color(0xFF63A97B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month Header ─────────────────────────────
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  monthLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2A34)
                      : const Color(0xFFF1F3F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  strings.mealCount(totalMeals),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFA7A5B0)
                        : const Color(0xFF70747A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Weekday Labels ───────────────────────────
          Row(
            children: weekdays
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // ── Calendar Grid ────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: firstDayOfWeek + daysCount,
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox.shrink();
              }

              final dayNum = index - firstDayOfWeek + 1;
              final dayData = days.firstWhere(
                (d) => d.date == dayNum,
                orElse: () => DayGroupData(
                  date: dayNum,
                  fullDate: '',
                  items: [],
                  isToday: false,
                ),
              );

              final hasMeal = dayData.items.isNotEmpty;
              final firstItem = hasMeal ? dayData.items.first : null;
              final quality = firstItem != null
                  ? NutritionCalculator.getMealQuality(
                      firstItem.totalCalo,
                      firstItem.totalProtein,
                    )
                  : null;

              final hasImage = firstItem?.thumbnailUrl != null ||
                  firstItem?.imageUrl != null;

              return GestureDetector(
                onTap: () {
                  if (hasMeal) {
                    onSelectDay(dayData);
                  } else if (dayData.isToday) {
                    onSelectTodayEmpty();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: hasMeal
                        ? (hasImage ? Colors.transparent : hasMealBg)
                        : emptyDayColor,
                    borderRadius: BorderRadius.circular(12),
                    border: dayData.isToday
                        ? Border.all(color: accentColor, width: 2.0)
                        : (quality != null && !hasImage)
                            ? Border.all(
                                color: quality.color.withOpacity(0.5),
                                width: 1.5,
                              )
                            : Border.all(
                                color: isDark
                                    ? Colors.transparent
                                    : borderColor.withOpacity(0.5),
                                width: 0.6,
                              ),
                  ),
                  child: Stack(
                    children: [
                      // Photo thumbnail
                      if (hasImage)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              dayData.isToday ? 9 : 11,
                            ),
                            child: Image.network(
                              firstItem!.thumbnailUrl ?? firstItem.imageUrl!,
                              fit: BoxFit.cover,
                              cacheWidth: 180,
                              filterQuality: FilterQuality.low,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),

                      // Gradient overlay on images so badge is legible
                      if (hasImage && dayData.items.length > 1)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              dayData.isToday ? 9 : 11,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Meal count badge
                      if (dayData.items.length > 1)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Text(
                              '+${dayData.items.length}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),

                      // Today "+" add indicator
                      if (dayData.isToday && !hasMeal)
                        Center(
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF24352A)
                                  : const Color(0xFFE2F1E7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: accentColor,
                              size: 15,
                            ),
                          ),
                        ),

                      // Day number for empty non-today cells
                      if (!hasMeal && !dayData.isToday)
                        Positioned(
                          top: 4,
                          left: 6,
                          child: Text(
                            '$dayNum',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor.withOpacity(0.65),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
