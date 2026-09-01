import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/macro_colors.dart';

/// Shows the main Target Nutrition Overview sheet in Profile Settings.
void showTargetNutritionModal(BuildContext context, bool isDark) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _TargetNutritionModalContent(isDark: isDark),
  );
}

class _TargetNutritionModalContent extends StatelessWidget {
  final bool isDark;

  const _TargetNutritionModalContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final strings = context.watch<AppSettingsProvider>().strings;

    final bgColor = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9);

    final dailyTarget = (user?.dailyCalorieTarget ?? 2000).round();
    final weightKg = user?.currentWeightKg ?? 70.0;

    // Macro calculation with fallback to default ratio if user macros not set
    final proteinG = (user?.proteinGrams ?? (weightKg * 2.0).clamp(80.0, dailyTarget * 0.35 / 4)).round();
    final fatG = (user?.fatGrams ?? (dailyTarget * 0.25 / 9)).round();
    final carbG = (user?.carbsGrams ?? ((dailyTarget - (proteinG * 4) - (fatG * 9)) / 4)).round().clamp(50, 600);

    final proteinKcal = proteinG * 4;
    final carbKcal = carbG * 4;
    final fatKcal = fatG * 9;
    final totalKcalSum = (proteinKcal + carbKcal + fatKcal).clamp(1, 10000);

    final proteinPct = (proteinKcal / totalKcalSum * 100).round();
    final carbPct = (carbKcal / totalKcalSum * 100).round();
    final fatPct = 100 - proteinPct - carbPct;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3F3B4D) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.nutritionTargetModalTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.4,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: mutedColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calorie Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFFF97316),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.dailyCalorieGoalKicker,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$dailyTarget',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.kcalPerDayUnit,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            strings.macroDistributionKicker,
            style: TextStyle(
              color: mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Stacked Macro Ratio Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: proteinPct,
                    child: Container(color: MacroColors.protein),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: carbPct,
                    child: Container(color: MacroColors.carb),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: fatPct,
                    child: Container(color: MacroColors.fat),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Macro cards list
          _MacroRowItem(
            label: strings.proteinMacroLabel,
            amount: '${proteinG}g',
            percentage: '$proteinPct%',
            calories: '$proteinKcal kcal',
            color: MacroColors.protein,
            isDark: isDark,
            borderColor: borderColor,
          ),
          const SizedBox(height: 10),
          _MacroRowItem(
            label: strings.carbMacroLabel,
            amount: '${carbG}g',
            percentage: '$carbPct%',
            calories: '$carbKcal kcal',
            color: MacroColors.carb,
            isDark: isDark,
            borderColor: borderColor,
          ),
          const SizedBox(height: 10),
          _MacroRowItem(
            label: strings.fatMacroLabel,
            amount: '${fatG}g',
            percentage: '$fatPct%',
            calories: '$fatKcal kcal',
            color: MacroColors.fat,
            isDark: isDark,
            borderColor: borderColor,
          ),
          const SizedBox(height: 24),

          // Recalculate Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openRecalculateWizard(context, isDark, user);
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                strings.recalculateTargetButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openRecalculateWizard(BuildContext context, bool isDark, User? user) async {
    final onboarding = context.read<OnboardingProvider>();
    await onboarding.startRecalculate(user);
    if (context.mounted) {
      context.go('/onboarding');
    }
  }
}

class _MacroRowItem extends StatelessWidget {
  final String label;
  final String amount;
  final String percentage;
  final String calories;
  final Color color;
  final bool isDark;
  final Color borderColor;

  const _MacroRowItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.calories,
    required this.color,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF262430) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amount ($percentage)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                calories,
                style: TextStyle(
                  fontSize: 11,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
