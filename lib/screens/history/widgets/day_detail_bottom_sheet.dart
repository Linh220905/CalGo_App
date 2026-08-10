import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final strings = context.watch<AppSettingsProvider>().strings;
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
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.mealCount(items.length),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close,
                      color: Color(0xFFA3A3A3), size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),

          // Macro Summary Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _MacroSummaryItem(
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFF59E0B),
                  text: strings.guidanceDishCalories(totalCalo.round()),
                  isBold: true,
                ),
                const SizedBox(width: 16),
                _MacroLabel(
                    label: 'C',
                    value: strings.gramsValue(totalCarb.round()),
                    color: const Color(0xFF60A5FA)),
                const SizedBox(width: 14),
                _MacroLabel(
                    label: 'P',
                    value: strings.gramsValue(totalProtein.round()),
                    color: const Color(0xFF4ADE80)),
                const SizedBox(width: 14),
                _MacroLabel(
                    label: 'F',
                    value: strings.gramsValue(totalFat.round()),
                    color: const Color(0xFFFBBF24)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),

          // Meals List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                        color: const Color(0xFF242424),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: quality.color, width: 2),
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
                                      Icons.restaurant,
                                      color: quality.color,
                                      size: 22,
                                    ),
                                  )
                                : Icon(
                                    Icons.restaurant,
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.totalCalo.round()}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: quality.color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _MacroLabel(
                                        label: 'C',
                                        value: strings
                                            .gramsValue(item.totalCarb.round()),
                                        color: const Color(0xFF60A5FA),
                                        small: true),
                                    const SizedBox(width: 8),
                                    _MacroLabel(
                                        label: 'P',
                                        value: strings.gramsValue(
                                            item.totalProtein.round()),
                                        color: const Color(0xFF4ADE80),
                                        small: true),
                                    const SizedBox(width: 8),
                                    _MacroLabel(
                                        label: 'F',
                                        value: strings
                                            .gramsValue(item.totalFat.round()),
                                        color: const Color(0xFFFBBF24),
                                        small: true),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.share_rounded,
                                color: Color(0xFF60A5FA), size: 18),
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
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF525252), size: 18),
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
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? color : const Color(0xFFA3A3A3),
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
  final bool small;

  const _MacroLabel({
    required this.label,
    required this.value,
    required this.color,
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
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA3A3A3),
          ),
        ),
      ],
    );
  }
}
