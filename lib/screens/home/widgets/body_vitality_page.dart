import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/home_data.dart';
import '../../../providers/app_settings_provider.dart';
import 'vitality_detail_sheet.dart';

class BodyVitalityPage extends StatelessWidget {
  final TodaySummary summary;
  final bool isPremium;
  final VoidCallback? onLockedTap;

  const BodyVitalityPage({
    super.key,
    required this.summary,
    required this.isPremium,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;

    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final trackColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final fillColor =
        isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D);
    final iconCircleBg =
        isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
    final iconColor =
        isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x060F172A),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.bodyVitalityTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                s.fourMetricsCount,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. Energy & Alertness
          _buildMetricRow(
            context: context,
            title: s.vitalityEnergyTitle,
            valueText: '${summary.energyVitality.round()}%',
            progressFactor: (summary.energyVitality / 100.0).clamp(0.0, 1.0),
            icon: Icons.lightbulb_outline_rounded,
            textDark: textDark,
            textMuted: textMuted,
            trackColor: trackColor,
            fillColor: fillColor,
            iconCircleBg: iconCircleBg,
            iconColor: iconColor,
            onTap: isPremium
                ? () => VitalityDetailSheet.show(
                      context,
                      VitalityDetailData(
                        key: 'energy',
                        title: s.vitalityEnergyDetailTitle,
                        score: '${summary.energyVitality.round()}%',
                        description: s.vitalityEnergyDetailDesc,
                        source: s.vitalityEnergyDetailSource,
                        sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/31952249/',
                        items: [
                          MapEntry(s.complexCarbRatioLabel, s.complexCarbRatioValue),
                          MapEntry(s.simpleSugarIntakeLabel, '${summary.sugarG}g (${s.whoLimit50g})'),
                        ],
                      ),
                    )
                : onLockedTap,
          ),

          // 2. Satiety & Cravings Control
          _buildMetricRow(
            context: context,
            title: s.vitalitySatietyTitle,
            valueText: '${summary.satietyVitality.toStringAsFixed(1)}/10',
            progressFactor: (summary.satietyVitality / 10.0).clamp(0.0, 1.0),
            icon: Icons.sentiment_satisfied_alt_rounded,
            textDark: textDark,
            textMuted: textMuted,
            trackColor: trackColor,
            fillColor: fillColor,
            iconCircleBg: iconCircleBg,
            iconColor: iconColor,
            onTap: isPremium
                ? () => VitalityDetailSheet.show(
                      context,
                      VitalityDetailData(
                        key: 'satiety',
                        title: s.vitalitySatietyDetailTitle,
                        score: '${summary.satietyVitality.toStringAsFixed(1)} / 10',
                        description: s.vitalitySatietyDetailDesc,
                        source: s.vitalitySatietyDetailSource,
                        sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/18469249/',
                        items: [
                          MapEntry(s.totalProteinLoggedLabel, '${summary.proteinG}g (${s.standardMetLabel})'),
                          MapEntry(s.totalFiberLoggedLabel, '${summary.fiberG}g / ${summary.targetFiberG}g'),
                          MapEntry(s.freeSugarRatioLabel, s.freeSugarRatioValue),
                        ],
                      ),
                    )
                : onLockedTap,
          ),

          // 3. Heart & Muscle Recovery
          _buildMetricRow(
            context: context,
            title: s.vitalityRecoveryTitle,
            valueText: '${summary.recoveryVitality.round()}%',
            progressFactor: (summary.recoveryVitality / 100.0).clamp(0.0, 1.0),
            icon: Icons.favorite_border_rounded,
            textDark: textDark,
            textMuted: textMuted,
            trackColor: trackColor,
            fillColor: fillColor,
            iconCircleBg: iconCircleBg,
            iconColor: iconColor,
            onTap: isPremium
                ? () => VitalityDetailSheet.show(
                      context,
                      VitalityDetailData(
                        key: 'recovery',
                        title: s.vitalityRecoveryDetailTitle,
                        score: '${summary.recoveryVitality.round()}%',
                        description: s.vitalityRecoveryDetailDesc,
                        source: s.vitalityRecoveryDetailSource,
                        sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/28642676/',
                        items: [
                          MapEntry(s.dietaryFiberIntakeLabel, '${summary.fiberG}g'),
                          MapEntry(s.satFatControlLabel, s.satFatControlValue),
                        ],
                      ),
                    )
                : onLockedTap,
          ),

          // 4. Sodium & Fluid Balance
          _buildMetricRow(
            context: context,
            title: s.vitalityBalanceTitle,
            valueText: '${summary.fluidBalanceVitality.round()}%',
            progressFactor: (summary.fluidBalanceVitality / 100.0).clamp(0.0, 1.0),
            icon: Icons.water_drop_outlined,
            textDark: textDark,
            textMuted: textMuted,
            trackColor: trackColor,
            fillColor: fillColor,
            iconCircleBg: iconCircleBg,
            iconColor: iconColor,
            onTap: isPremium
                ? () => VitalityDetailSheet.show(
                      context,
                      VitalityDetailData(
                        key: 'balance',
                        title: s.vitalityBalanceDetailTitle,
                        score: '${summary.fluidBalanceVitality.round()}%',
                        description: s.vitalityBalanceDetailDesc,
                        source: s.vitalityBalanceDetailSource,
                        sourceUrl: 'https://www.who.int/news-room/fact-sheets/detail/salt-reduction',
                        items: [
                          MapEntry(s.sodiumConsumedLabel, '${summary.sodiumMg}mg'),
                          MapEntry(s.maxRecommendedLabel, '${summary.targetSodiumMg}mg/day'),
                        ],
                      ),
                    )
                : onLockedTap,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required BuildContext context,
    required String title,
    required String valueText,
    required double progressFactor,
    required IconData icon,
    required Color textDark,
    required Color textMuted,
    required Color trackColor,
    required Color fillColor,
    required Color iconCircleBg,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconCircleBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isPremium)
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                child: Text(
                                  '-- / --',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: textMuted.withValues(alpha: 0.5),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              )
                            else
                              Text(
                                valueText,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: isPremium
                                  ? textMuted
                                  : textMuted.withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Progress Track
                    if (!isPremium)
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: trackColor,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          height: 6,
                          color: trackColor,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressFactor,
                            child: Container(
                              decoration: BoxDecoration(
                                color: fillColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
