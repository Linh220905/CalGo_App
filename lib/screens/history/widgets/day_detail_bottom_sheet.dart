import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/history_item.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../utils/nutrition_calculator.dart';
import '../../../widgets/swipeable_card.dart';
import '../../../widgets/share_card_modal.dart';

class DayDetailBottomSheet extends StatelessWidget {
  final String dateLabel;
  final List<HistoryItem> items;
  final Function(String id) onDeleteMeal;

  const DayDetailBottomSheet({
    super.key,
    required this.dateLabel,
    required this.items,
    required this.onDeleteMeal,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final strings = settings.strings;

    final sheetBg = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF34313D) : const Color(0xFFEDEDEB);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111318);
    final mutedTextColor =
        isDark ? const Color(0xFFA7A5B0) : const Color(0xFF747780);
    final summaryBg =
        isDark ? const Color(0xFF141318) : const Color(0xFFF8FAFC);
    final itemBg = isDark ? const Color(0xFF1A1920) : const Color(0xFFF8FAFC);
    final handleColor =
        isDark ? const Color(0xFF4A4653) : const Color(0xFFE2E8F0);
    final closeBtnBg =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F3F2);
    final closeBtnIcon =
        isDark ? Colors.white70 : const Color(0xFF70747A);

    double totalCalo = 0;
    double totalCarb = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (final item in items) {
      totalCalo += item.totalCalo;
      totalCarb += item.totalCarb;
      totalProtein += item.totalProtein;
      totalFat += item.totalFat;
    }

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.mealCount(items.length),
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: closeBtnIcon,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: closeBtnBg,
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // Macro Summary Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: summaryBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    _MacroSummaryItem(
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF97316),
                      text: strings.guidanceDishCalories(totalCalo.round()),
                      isBold: true,
                    ),
                    const Spacer(),
                    _MacroLabel(
                      label: 'C',
                      value: strings.gramsValue(totalCarb.round()),
                      color: const Color(0xFFF59E0B),
                      mutedColor: mutedTextColor,
                    ),
                    const SizedBox(width: 14),
                    _MacroLabel(
                      label: 'P',
                      value: strings.gramsValue(totalProtein.round()),
                      color: const Color(0xFFFF5C5C),
                      mutedColor: mutedTextColor,
                    ),
                    const SizedBox(width: 14),
                    _MacroLabel(
                      label: 'F',
                      value: strings.gramsValue(totalFat.round()),
                      color: const Color(0xFF3B82F6),
                      mutedColor: mutedTextColor,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: borderColor),

            // Meals List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final quality = NutritionCalculator.getMealQuality(
                    item.totalCalo,
                    item.totalProtein,
                  );

                  return SwipeableCard(
                    confirmMessage: strings.deleteMealConfirm,
                    onDelete: () => onDeleteMeal(item.id),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/result/${item.id}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: itemBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2A34)
                                    : const Color(0xFFF1F3F2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: quality.color.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: item.thumbnailUrl != null ||
                                      item.imageUrl != null
                                  ? Image.network(
                                      item.thumbnailUrl ?? item.imageUrl!,
                                      fit: BoxFit.cover,
                                      cacheWidth: 160,
                                      filterQuality: FilterQuality.low,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.restaurant_rounded,
                                        color: quality.color,
                                        size: 22,
                                      ),
                                    )
                                  : Icon(
                                      Icons.restaurant_rounded,
                                      color: quality.color,
                                      size: 22,
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.monChinh,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: primaryTextColor,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${item.totalCalo.round()} kcal',
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _MacroLabel(
                                        label: 'C',
                                        value: strings.gramsValue(
                                          item.totalCarb.round(),
                                        ),
                                        color: const Color(0xFFF59E0B),
                                        mutedColor: mutedTextColor,
                                        small: true,
                                      ),
                                      const SizedBox(width: 10),
                                      _MacroLabel(
                                        label: 'P',
                                        value: strings.gramsValue(
                                          item.totalProtein.round(),
                                        ),
                                        color: const Color(0xFFFF5C5C),
                                        mutedColor: mutedTextColor,
                                        small: true,
                                      ),
                                      const SizedBox(width: 10),
                                      _MacroLabel(
                                        label: 'F',
                                        value: strings.gramsValue(
                                          item.totalFat.round(),
                                        ),
                                        color: const Color(0xFF3B82F6),
                                        mutedColor: mutedTextColor,
                                        small: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.share_rounded,
                                color: Color(0xFF63A97B),
                                size: 18,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF24352A)
                                    : const Color(0xFFE2F1E7),
                                padding: const EdgeInsets.all(6),
                                minimumSize: const Size(32, 32),
                              ),
                              onPressed: () {
                                ShareCardModal.show(
                                  context,
                                  CardMemoryData(
                                    dishName: item.monChinh,
                                    imageUrl: item.imageUrl ?? item.thumbnailUrl,
                                    calories: item.totalCalo,
                                    carbs: item.totalCarb,
                                    protein: item.totalProtein,
                                    fat: item.totalFat,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? const Color(0xFF777482)
                                  : const Color(0xFFB4B5B5),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calo row (icon + text) ───────────────────────────────────────────────────
class _MacroSummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final bool isBold;

  const _MacroSummaryItem({
    required this.icon,
    required this.color,
    required this.text,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.beVietnamPro(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── C / P / F label + value (no duplication) ─────────────────────────────────
class _MacroLabel extends StatelessWidget {
  final String label; // 'C', 'P', or 'F'
  final String value; // e.g. '45g'
  final Color color;
  final Color mutedColor;
  final bool small;

  const _MacroLabel({
    required this.label,
    required this.value,
    required this.color,
    required this.mutedColor,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = small ? 10.0 : 11.0;
    final valueSize = small ? 11.0 : 12.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: labelSize,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: GoogleFonts.beVietnamPro(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: mutedColor,
          ),
        ),
      ],
    );
  }
}
