import '../config/app_build_config.dart';

class MealGuidanceDish {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int? prepTimeMin;
  final int? priceVnd;
  final String fit;
  final String adjustment;
  final String reason;
  final bool isFamiliar;
  final bool personalMacroMatch;
  final double personalFitScore;

  const MealGuidanceDish({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.prepTimeMin,
    this.priceVnd,
    required this.fit,
    required this.adjustment,
    required this.reason,
    required this.isFamiliar,
    required this.personalMacroMatch,
    required this.personalFitScore,
  });

  factory MealGuidanceDish.fromJson(Map<String, dynamic> json) =>
      MealGuidanceDish(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        calories: (json['calories_kcal'] as num?)?.toDouble() ?? 0,
        protein: (json['protein_g'] as num?)?.toDouble() ?? 0,
        carbs: (json['carbs_g'] as num?)?.toDouble() ?? 0,
        fat: (json['fat_g'] as num?)?.toDouble() ?? 0,
        prepTimeMin: (json['prep_time_min'] as num?)?.toInt(),
        priceVnd: (json['price_vnd'] as num?)?.toInt(),
        fit: json['fit']?.toString() ?? 'good',
        adjustment: json['adjustment']?.toString() ?? '',
        reason: json['reason']?.toString() ?? '',
        isFamiliar: json['is_familiar'] == true,
        personalMacroMatch: json['personal_macro_match'] == true,
        personalFitScore: (json['personal_fit_score'] as num?)?.toDouble() ?? 0,
      );
}

class MealGuidanceSummary {
  final double caloriesRemaining;
  final double proteinRemaining;
  final int mealCount;
  final String nextMeal;

  const MealGuidanceSummary({
    required this.caloriesRemaining,
    required this.proteinRemaining,
    required this.mealCount,
    required this.nextMeal,
  });

  factory MealGuidanceSummary.fromJson(Map<String, dynamic> json) =>
      MealGuidanceSummary(
        caloriesRemaining:
            (json['calories_remaining'] as num?)?.toDouble() ?? 0,
        proteinRemaining: (json['protein_remaining'] as num?)?.toDouble() ?? 0,
        mealCount: (json['meal_count'] as num?)?.toInt() ?? 0,
        nextMeal: json['next_meal']?.toString() ?? '',
      );
}

class MealGuidance {
  final String state;
  final String title;
  final String message;
  final String mascotState;
  final MealGuidanceSummary? summary;
  final List<MealGuidanceDish> recommendations;
  final bool generatedWithLlm;
  final int llmCallsRemaining;
  final bool isPremium;

  const MealGuidance({
    required this.state,
    required this.title,
    required this.message,
    required this.mascotState,
    required this.summary,
    required this.recommendations,
    required this.generatedWithLlm,
    required this.llmCallsRemaining,
    required this.isPremium,
  });

  bool get needsFirstScan => state == 'needs_first_scan';
  bool get isRecovery => state == 'recovery';
  // Defensive client-side guard: older servers may still have a cached
  // `recovery` response, but Home must never show food suggestions after the
  // calorie budget is exhausted.
  bool get goalReached =>
      state == 'goal_reached' || (summary?.caloriesRemaining ?? 1) <= 0;
  bool get isAvailable =>
      (state == 'ready' || state == 'recovery') && !goalReached;
  bool get hasPremiumAccess =>
      AppBuildConfig.premiumFreeForTesting || isPremium;

  factory MealGuidance.fromJson(Map<String, dynamic> json) {
    final rawRecommendations = json['recommendations'];
    return MealGuidance(
      state: json['state']?.toString() ?? 'unavailable',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      mascotState: json['mascot_state']?.toString() ?? 'idle',
      summary: json['summary'] is Map<String, dynamic>
          ? MealGuidanceSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
      recommendations: rawRecommendations is List
          ? rawRecommendations
              .whereType<Map>()
              .map((item) =>
                  MealGuidanceDish.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
      generatedWithLlm: json['generated_with_llm'] == true,
      llmCallsRemaining: (json['llm_calls_remaining'] as num?)?.toInt() ?? 0,
      isPremium: json['is_premium'] == true,
    );
  }
}
