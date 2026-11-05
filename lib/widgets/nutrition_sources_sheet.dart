import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_settings_provider.dart';

class NutritionSourcesSheet extends StatelessWidget {
  const NutritionSourcesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NutritionSourcesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final strings = settings.strings;

    final sheetBg = isDark ? const Color(0xFF1A1C24) : Colors.white;
    final handleColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final boxBg = isDark ? const Color(0xFF141318) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final linkColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: linkColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: linkColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.nutritionSourcesTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.nutritionSourcesSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Calorie Target (BMR & TDEE)
                  _SourceCard(
                    title: strings.calorieCalculationSourceTitle,
                    description: strings.calorieCalculationSourceDesc,
                    citations: [
                      _CitationLink(
                        label: strings.mifflinStJeorCitation,
                        url: 'https://pubmed.ncbi.nlm.nih.gov/2305711/',
                        color: linkColor,
                      ),
                      _CitationLink(
                        label: strings.faoWhoEnergyCitation,
                        url: 'https://www.fao.org/3/y5686e/y5686e00.htm',
                        color: linkColor,
                      ),
                    ],
                    boxBg: boxBg,
                    borderColor: borderColor,
                    textDark: textDark,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),

                  // 2. Macronutrient Distribution
                  _SourceCard(
                    title: strings.macroDistributionSourceTitle,
                    description: strings.macroDistributionSourceDesc,
                    citations: [
                      _CitationLink(
                        label: strings.usdaDietaryCitation,
                        url: 'https://www.dietaryguidelines.gov/',
                        color: linkColor,
                      ),
                      _CitationLink(
                        label: 'Harvard School of Public Health – Nutrition Source',
                        url: 'https://www.hsph.harvard.edu/nutritionsource/what-should-you-eat/protein/',
                        color: linkColor,
                      ),
                    ],
                    boxBg: boxBg,
                    borderColor: borderColor,
                    textDark: textDark,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),

                  // 3. Safe Rate of Weight Change
                  _SourceCard(
                    title: strings.safeWeightRateSourceTitle,
                    description: strings.safeWeightRateSourceDesc,
                    citations: [
                      _CitationLink(
                        label: strings.cdcWeightLossCitation,
                        url: 'https://www.cdc.gov/healthy-weight-growth/losing-weight/',
                        color: linkColor,
                      ),
                      _CitationLink(
                        label: 'NIH – Aim for a Healthy Weight Guidelines',
                        url: 'https://www.nhlbi.nih.gov/health/educational/lose_wt/eat/calories.htm',
                        color: linkColor,
                      ),
                    ],
                    boxBg: boxBg,
                    borderColor: borderColor,
                    textDark: textDark,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),

                  // 4. BMI & Micronutrients
                  _SourceCard(
                    title: strings.bmiMicronutrientSourceTitle,
                    description: strings.bmiMicronutrientSourceDesc,
                    citations: [
                      _CitationLink(
                        label: strings.bmiReferenceSource,
                        url: 'https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight',
                        color: linkColor,
                      ),
                      _CitationLink(
                        label: strings.sugarDetailSource,
                        url: 'https://www.who.int/publications/i/item/9789241549028',
                        color: linkColor,
                      ),
                      _CitationLink(
                        label: strings.sodiumDetailSource,
                        url: 'https://www.who.int/news-room/fact-sheets/detail/salt-reduction',
                        color: linkColor,
                      ),
                    ],
                    boxBg: boxBg,
                    borderColor: borderColor,
                    textDark: textDark,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer at bottom
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF23212C) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.medicalDisclaimerNote,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: textMuted,
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
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final String title;
  final String description;
  final List<_CitationLink> citations;
  final Color boxBg;
  final Color borderColor;
  final Color textDark;
  final Color textMuted;

  const _SourceCard({
    required this.title,
    required this.description,
    required this.citations,
    required this.boxBg,
    required this.borderColor,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 10),
          ...citations.map((c) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: InkWell(
                  onTap: () => launchUrl(
                    Uri.parse(c.url),
                    mode: LaunchMode.externalApplication,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 13,
                          color: c.color,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: c.color,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _CitationLink {
  final String label;
  final String url;
  final Color color;

  const _CitationLink({
    required this.label,
    required this.url,
    required this.color,
  });
}
