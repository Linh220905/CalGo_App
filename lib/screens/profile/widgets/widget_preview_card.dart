import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/macro_icons.dart';
import 'how_to_add_widget_dialog.dart';

class WidgetPreviewCard extends StatelessWidget {
  final bool isDark;

  const WidgetPreviewCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final home = context.watch<HomeProvider>();
    final auth = context.watch<AuthProvider>();

    final summary = home.summary;
    final targetCalories = auth.user?.dailyCalorieTarget.round() ??
        summary.targetCalories;
    final consumedCalories = summary.consumedCalories;
    final caloriesLeft = (targetCalories - consumedCalories).clamp(0, 99999);

    final proteinLeft = (summary.targetProteinG - summary.proteinG).clamp(0, 999);
    final carbsLeft = (summary.targetCarbG - summary.carbG).clamp(0, 999);
    final fatsLeft = (summary.targetFatG - summary.fatG).clamp(0, 999);

    final cardBgColor = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: "Widgets" and "How to add?"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.widgetsSection.toUpperCase(),
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            GestureDetector(
              onTap: () => HowToAddWidgetDialog.show(context, isDark: isDark),
              child: Text(
                s.howToAddWidget,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Widgets Row: Left Main Macro Card + Right 2 Separate Action Cards
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Left Card: Calories Left Ring + Macros Stack
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x22000000) : const Color(0x080F172A),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Calories Left Ring
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: targetCalories > 0
                                        ? (consumedCalories / targetCalories).clamp(0.0, 1.0)
                                        : 0.0,
                                    strokeWidth: 6.5,
                                    backgroundColor: isDark
                                        ? const Color(0xFF2C2A34)
                                        : const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$caloriesLeft',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      s.caloriesLeft,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w500,
                                        color: mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Macro Left List (Protein, Carbs, Fats)
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMacroItem(
                              icon: MacroIcons.protein(size: 14),
                              amount: '${proteinLeft}g',
                              label: s.proteinLeft,
                              textColor: textColor,
                              mutedColor: mutedColor,
                            ),
                            const SizedBox(height: 7),
                            _buildMacroItem(
                              icon: MacroIcons.carb(size: 14),
                              amount: '${carbsLeft}g',
                              label: s.carbsLeft,
                              textColor: textColor,
                              mutedColor: mutedColor,
                            ),
                            const SizedBox(height: 7),
                            _buildMacroItem(
                              icon: MacroIcons.fat(size: 14),
                              amount: '${fatsLeft}g',
                              label: s.fatsLeft,
                              textColor: textColor,
                              mutedColor: mutedColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Right: 2 Separate Action Cards (Scan Food & Barcode)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        label: s.scanFood,
                        route: '/scan',
                        bgColor: cardBgColor,
                        borderColor: borderColor,
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.qr_code_scanner_rounded,
                        label: s.barcode,
                        route: '/barcode-scan',
                        bgColor: cardBgColor,
                        borderColor: borderColor,
                        textColor: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem({
    required Widget icon,
    required String amount,
    required String label,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 16, height: 16, child: Center(child: icon)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: mutedColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x22000000) : const Color(0x080F172A),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2834) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, size: 16, color: textColor),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
