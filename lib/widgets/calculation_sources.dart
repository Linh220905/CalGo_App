import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import 'nutrition_sources_sheet.dart';

enum CalculationSourceType {
  calorieGoal,
  weightPace,
  activityGuidance,
  nutrients,
  exercise,
  foodEstimate,
  mealGuidance,
  weightForecast,
}

/// Keeps the references next to the estimates they explain, including for
/// users who have not purchased Premium.
class CalculationSources extends StatelessWidget {
  const CalculationSources({super.key, required this.type, this.dark = false});

  final CalculationSourceType type;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final (note, sources) = switch (type) {
      CalculationSourceType.calorieGoal => (
        s.calorieCalculationNote,
        <(String, String)>[
          (s.sourceMifflin, 'https://pubmed.ncbi.nlm.nih.gov/2305711/'),
          (
            s.sourceActivityFactor,
            'https://www.fao.org/3/y5686e/y5686e00.htm',
          ),
          (
            s.sourceCdcWeight,
            'https://www.cdc.gov/healthy-weight-growth/losing-weight/index.html',
          ),
          (
            s.sourceMacroDri,
            'https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-macronutrients.html',
          ),
        ],
      ),
      CalculationSourceType.weightPace => (
        s.paceCalculationNote,
        <(String, String)>[
          (
            s.sourceCdcWeight,
            'https://www.cdc.gov/healthy-weight-growth/losing-weight/index.html',
          ),
        ],
      ),
      CalculationSourceType.activityGuidance => (
        s.activityGuidanceNote,
        <(String, String)>[
          (
            s.sourceWhoActivity,
            'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
          ),
        ],
      ),
      CalculationSourceType.nutrients => (
        s.nutrientCalculationNote,
        <(String, String)>[
          (
            s.sourceMacroDri,
            'https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-macronutrients.html',
          ),
          (s.sourceWhoDiet, 'https://www.who.int/health-topics/healthy-diet'),
        ],
      ),
      CalculationSourceType.exercise => (
        s.exerciseCalculationNote,
        <(String, String)>[
          (
            s.sourceActivityCompendium,
            'https://pacompendium.com/adult-compendium/',
          ),
        ],
      ),
      CalculationSourceType.foodEstimate => (
        s.foodCalculationNote,
        <(String, String)>[
          (s.sourceWhoDiet, 'https://www.who.int/health-topics/healthy-diet'),
          (
            s.sourceMacroDri,
            'https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-macronutrients.html',
          ),
          (
            s.sourceMineralDri,
            'https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-elements.html',
          ),
        ],
      ),
      CalculationSourceType.mealGuidance => (
        s.mealGuidanceSourcesNote,
        <(String, String)>[
          (s.sourceWhoDiet, 'https://www.who.int/health-topics/healthy-diet'),
          (
            s.sourceMacroDri,
            'https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-macronutrients.html',
          ),
        ],
      ),
      CalculationSourceType.weightForecast => (
        s.weightForecastSourcesNote,
        <(String, String)>[
          (
            s.sourceNihWeightPlanner,
            'https://www.niddk.nih.gov/health-information/professionals/diabetes-discoveries-practice/nih-body-weight-planner',
          ),
          (
            s.sourceCdcWeight,
            'https://www.cdc.gov/healthy-weight-growth/losing-weight/index.html',
          ),
        ],
      ),
    };
    final muted = dark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    final link = dark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);

    return Semantics(
      container: true,
      label: s.calculationSourcesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                s.calculationSourcesTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: muted,
                ),
              ),
              InkWell(
                onTap: () => NutritionSourcesSheet.show(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.menu_book_rounded, size: 13, color: link),
                          ),
                        ),
                        TextSpan(
                          text: s.nutritionSourcesTitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: link,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: TextStyle(fontSize: 11, height: 1.35, color: muted),
          ),
          const SizedBox(height: 4),
          for (final (label, url) in sources)
            InkWell(
              onTap: () => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.open_in_new_rounded, size: 13, color: link),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: link,
                          decoration: TextDecoration.underline,
                        ),
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
