import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/history_item.dart';
import '../../../utils/nutrition_calculator.dart';

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
  });

  static const _weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  Widget build(BuildContext context) {
    final daysCount = DateTime(year, month + 1, 0).day;
    final firstDayOfWeek = DateTime(year, month, 1).weekday % 7; // 0=Sun

    final emptyDayColor =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final hasMealBg =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8ED);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month Header ─────────────────────────────
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F0A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9F0A).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                monthLabel,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '$totalMeals bữa',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Weekday Labels ───────────────────────────
          Row(
            children: _weekdays
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                        letterSpacing: 0.2,
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
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
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
                    borderRadius: BorderRadius.circular(10),
                    border: dayData.isToday
                        ? Border.all(color: const Color(0xFFFF9F0A), width: 2.0)
                        : (quality != null && !hasImage)
                            ? Border.all(
                                color: quality.color.withOpacity(0.5),
                                width: 1.5,
                              )
                            : null,
                  ),
                  child: Stack(
                    children: [
                      // Photo thumbnail
                      if (hasImage)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(dayData.isToday ? 8 : 10),
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
                            borderRadius:
                                BorderRadius.circular(dayData.isToday ? 8 : 10),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.35),
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
                          top: -1,
                          right: -1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF9F0A),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                            child: Text(
                              '+${dayData.items.length}',
                              style: const TextStyle(
                                fontSize: 8,
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
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9F0A).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFFFF9F0A),
                              size: 14,
                            ),
                          ),
                        ),

                      // Day number for empty non-today cells
                      if (!hasMeal && !dayData.isToday)
                        Positioned(
                          top: 3,
                          left: 5,
                          child: Text(
                            '$dayNum',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: subtitleColor.withOpacity(0.7),
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
