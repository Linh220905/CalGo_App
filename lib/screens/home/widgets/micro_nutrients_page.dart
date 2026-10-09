import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/home_data.dart';
import '../../../providers/app_settings_provider.dart';
import 'cal_ai_macro_card.dart';
import 'vitality_detail_sheet.dart';

class MicroNutrientsPage extends StatelessWidget {
  final TodaySummary summary;
  final bool isPremium;
  final VoidCallback? onLockedTap;

  const MicroNutrientsPage({
    super.key,
    required this.summary,
    required this.isPremium,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final strings = settings.strings;

    final targetFiber = summary.targetFiberG > 0 ? summary.targetFiberG : 38;
    final targetSugar = summary.targetSugarG > 0 ? summary.targetSugarG : 50;
    final targetSodium =
        summary.targetSodiumMg > 0 ? summary.targetSodiumMg : 2000;

    final fiberG = summary.fiberG;
    final sugarG = summary.sugarG;
    final sodiumMg = summary.sodiumMg;

    final fiberLeft = (targetFiber - fiberG).clamp(0, targetFiber);
    final sugarLeft = (targetSugar - sugarG).clamp(0, targetSugar);
    final sodiumLeft = (targetSodium - sodiumMg).clamp(0, targetSodium);

    const fiberColor = Color(0xFF8B5CF6);
    const sugarColor = Color(0xFFEC4899);
    const sodiumColor = Color(0xFF10B981);

    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final ringTrackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 3 Micro Cards (Fiber, Sugar, Sodium)
        Row(
          children: [
            // Fiber
            Expanded(
              child: CalAiMacroCard(
                title: strings.gramsValue(fiberLeft),
                subtitle: strings.fiberLabel,
                consumed: fiberG,
                target: targetFiber,
                progress: (fiberG / targetFiber).clamp(0.0, 1.0),
                color: fiberColor,
                trackColor: const Color(0xFFEDE9FE),
                bgIconColor: const Color(0xFFF5F3FF),
                isLocked: !isPremium,
                unit: 'g',
                iconWidget: const Icon(
                  Icons.eco_rounded,
                  size: 16,
                  color: fiberColor,
                ),
                onTap: isPremium
                    ? () => VitalityDetailSheet.show(
                          context,
                          VitalityDetailData(
                            key: 'fiber',
                            title: strings.fiberDetailTitle,
                            score: '${fiberG}g / ${targetFiber}g',
                            description: strings.fiberDetailDesc,
                            source: strings.fiberDetailSource,
                            items: [
                              MapEntry(strings.intakeConsumedLabel, '${fiberG}g'),
                              MapEntry(strings.dailyGoalLabel, '${targetFiber}g'),
                            ],
                          ),
                        )
                    : onLockedTap,
              ),
            ),
            const SizedBox(width: 10),

            // Sugar
            Expanded(
              child: CalAiMacroCard(
                title: strings.gramsValue(sugarLeft),
                subtitle: strings.sugarLabel,
                consumed: sugarG,
                target: targetSugar,
                progress: (sugarG / targetSugar).clamp(0.0, 1.0),
                color: sugarColor,
                trackColor: const Color(0xFFFCE7F3),
                bgIconColor: const Color(0xFFFDF2F8),
                isLocked: !isPremium,
                unit: 'g',
                iconWidget: const Icon(
                  Icons.cookie_outlined,
                  size: 17,
                  color: sugarColor,
                ),
                onTap: isPremium
                    ? () => VitalityDetailSheet.show(
                          context,
                          VitalityDetailData(
                            key: 'sugar',
                            title: strings.sugarDetailTitle,
                            score: '${sugarG}g / ${targetSugar}g',
                            description: strings.sugarDetailDesc,
                            source: strings.sugarDetailSource,
                            items: [
                              MapEntry(strings.intakeConsumedLabel, '${sugarG}g'),
                              MapEntry(strings.safeLimitLabel, '${targetSugar}g/day'),
                            ],
                          ),
                        )
                    : onLockedTap,
              ),
            ),
            const SizedBox(width: 10),

            // Sodium
            Expanded(
              child: CalAiMacroCard(
                title: '${sodiumLeft}mg',
                subtitle: strings.sodiumLabel,
                consumed: sodiumMg,
                target: targetSodium,
                progress: (sodiumMg / targetSodium).clamp(0.0, 1.0),
                color: sodiumColor,
                trackColor: const Color(0xFFD1FAE5),
                bgIconColor: const Color(0xFFECFDF5),
                isLocked: !isPremium,
                unit: 'mg',
                iconWidget: const Icon(
                  Icons.opacity_rounded,
                  size: 17,
                  color: sodiumColor,
                ),
                onTap: isPremium
                    ? () => VitalityDetailSheet.show(
                          context,
                          VitalityDetailData(
                            key: 'sodium',
                            title: strings.sodiumDetailTitle,
                            score: '${sodiumMg}mg / ${targetSodium}mg',
                            description: strings.sodiumDetailDesc,
                            source: strings.sodiumDetailSource,
                            items: [
                              MapEntry(strings.intakeConsumedLabel, '${sodiumMg}mg'),
                              MapEntry(strings.maxRecommendedLabel, '${targetSodium}mg/day'),
                            ],
                          ),
                        )
                    : onLockedTap,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Health Score Card (Clean Linear Horizontal Progress)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isPremium
                ? () => VitalityDetailSheet.show(
                      context,
                      VitalityDetailData(
                        key: 'health_score',
                        title: strings.healthScoreTitle,
                        score: '${summary.healthScore.toStringAsFixed(1)} / 10',
                        description: strings.healthScoreDetailDesc,
                        source: strings.healthScoreSource,
                        items: [
                          MapEntry(strings.proteinBalanceLabel, '${summary.proteinG}g / ${summary.targetProteinG}g'),
                          MapEntry(strings.fiberQualityLabel, '${summary.fiberG}g / ${targetFiber}g'),
                          MapEntry(strings.freeSugarControlLabel, '${summary.sugarG}g / ${targetSugar}g'),
                        ],
                      ),
                    )
                : onLockedTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x22000000) : const Color(0x060F172A),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
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
                        strings.healthScoreTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (!isPremium)
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                          child: Text(
                            '-- / 10',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textMuted.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      else
                        Text(
                          '${summary.healthScore.toStringAsFixed(1)} / 10',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Linear progress track
                  if (!isPremium)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Opacity(
                        opacity: 0.55,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: ringTrackColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 7,
                        color: ringTrackColor,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (summary.healthScore / 10.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    strings.healthScoreSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
