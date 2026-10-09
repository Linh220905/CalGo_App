import '../config/api_config.dart';
import '../utils/date_time_utils.dart';

class TodaySummary {
  final int consumedCalories;
  final int burnedCalories;
  final int targetCalories;
  final int proteinG;
  final int targetProteinG;
  final int carbG;
  final int targetCarbG;
  final int fatG;
  final int targetFatG;
  // Micronutrients
  final int fiberG;
  final int targetFiberG;
  final int sugarG;
  final int targetSugarG;
  final int sodiumMg;
  final int targetSodiumMg;
  // Health & Body Vitality Indices
  final double healthScore;
  final double energyVitality;
  final double satietyVitality;
  final double recoveryVitality;
  final double fluidBalanceVitality;
  final int streakDays;
  final double currentWeightKg;
  final double targetWeightKg;
  final String? aiMessage;

  TodaySummary({
    this.consumedCalories = 0,
    this.burnedCalories = 0,
    this.targetCalories = 2000,
    this.proteinG = 0,
    this.targetProteinG = 130,
    this.carbG = 0,
    this.targetCarbG = 200,
    this.fatG = 0,
    this.targetFatG = 60,
    this.fiberG = 0,
    this.targetFiberG = 38,
    this.sugarG = 0,
    this.targetSugarG = 50,
    this.sodiumMg = 0,
    this.targetSodiumMg = 2000,
    this.healthScore = 8.5,
    this.energyVitality = 84.0,
    this.satietyVitality = 8.3,
    this.recoveryVitality = 72.0,
    this.fluidBalanceVitality = 88.0,
    this.streakDays = 0,
    this.currentWeightKg = 0,
    this.targetWeightKg = 0,
    this.aiMessage,
  });

  int get effectiveTargetCalories => targetCalories + burnedCalories;
  int get remainingCalories =>
      (effectiveTargetCalories - consumedCalories)
          .clamp(0, effectiveTargetCalories);
  double get caloriesProgress =>
      effectiveTargetCalories > 0
          ? (consumedCalories / effectiveTargetCalories).clamp(0, 1)
          : 0;
  double get proteinProgress =>
      targetProteinG > 0 ? (proteinG / targetProteinG).clamp(0, 1) : 0;
  double get carbProgress =>
      targetCarbG > 0 ? (carbG / targetCarbG).clamp(0, 1) : 0;
  double get fatProgress =>
      targetFatG > 0 ? (fatG / targetFatG).clamp(0, 1) : 0;
  double get fiberProgress =>
      targetFiberG > 0 ? (fiberG / targetFiberG).clamp(0, 1) : 0;
  double get sugarProgress =>
      targetSugarG > 0 ? (sugarG / targetSugarG).clamp(0, 1) : 0;
  double get sodiumProgress =>
      targetSodiumMg > 0 ? (sodiumMg / targetSodiumMg).clamp(0, 1) : 0;

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      consumedCalories: (json['total_calo'] as num?)?.toInt() ??
          (json['consumedCalories'] as num?)?.toInt() ??
          0,
      burnedCalories: (json['burnedCalories'] as num?)?.toInt() ?? 0,
      targetCalories: (json['target_calories'] as num?)?.toInt() ??
          (json['targetCalories'] as num?)?.toInt() ??
          2000,
      proteinG: (json['total_protein'] as num?)?.toInt() ??
          (json['proteinG'] as num?)?.toInt() ??
          0,
      targetProteinG: (json['target_protein'] as num?)?.toInt() ??
          (json['targetProteinG'] as num?)?.toInt() ??
          130,
      carbG: (json['total_carb'] as num?)?.toInt() ??
          (json['carbG'] as num?)?.toInt() ??
          0,
      targetCarbG: (json['target_carb'] as num?)?.toInt() ??
          (json['targetCarbG'] as num?)?.toInt() ??
          200,
      fatG: (json['total_fat'] as num?)?.toInt() ??
          (json['fatG'] as num?)?.toInt() ??
          0,
      targetFatG: (json['target_fat'] as num?)?.toInt() ??
          (json['targetFatG'] as num?)?.toInt() ??
          60,
      fiberG: (json['total_fiber'] as num?)?.toInt() ??
          (json['fiberG'] as num?)?.toInt() ??
          (json['fiber'] as num?)?.toInt() ??
          0,
      targetFiberG: (json['target_fiber'] as num?)?.toInt() ??
          (json['targetFiberG'] as num?)?.toInt() ??
          38,
      sugarG: (json['total_sugar'] as num?)?.toInt() ??
          (json['sugarG'] as num?)?.toInt() ??
          (json['sugar'] as num?)?.toInt() ??
          0,
      targetSugarG: (json['target_sugar'] as num?)?.toInt() ??
          (json['targetSugarG'] as num?)?.toInt() ??
          50,
      sodiumMg: (json['total_sodium'] as num?)?.toInt() ??
          (json['sodiumMg'] as num?)?.toInt() ??
          (json['sodium'] as num?)?.toInt() ??
          0,
      targetSodiumMg: (json['target_sodium'] as num?)?.toInt() ??
          (json['targetSodiumMg'] as num?)?.toInt() ??
          2000,
      healthScore: (json['health_score'] as num?)?.toDouble() ??
          (json['healthScore'] as num?)?.toDouble() ??
          8.5,
      energyVitality: (json['energy_vitality'] as num?)?.toDouble() ??
          (json['energyVitality'] as num?)?.toDouble() ??
          84.0,
      satietyVitality: (json['satiety_vitality'] as num?)?.toDouble() ??
          (json['satietyVitality'] as num?)?.toDouble() ??
          8.3,
      recoveryVitality: (json['recovery_vitality'] as num?)?.toDouble() ??
          (json['recoveryVitality'] as num?)?.toDouble() ??
          72.0,
      fluidBalanceVitality: (json['fluid_balance_vitality'] as num?)?.toDouble() ??
          (json['fluidBalanceVitality'] as num?)?.toDouble() ??
          88.0,
      streakDays: (json['streak'] as num?)?.toInt() ??
          (json['streakDays'] as num?)?.toInt() ??
          0,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble() ??
          (json['currentWeightKg'] as num?)?.toDouble() ??
          0,
      targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble() ??
          (json['targetWeightKg'] as num?)?.toDouble() ??
          0,
      aiMessage: json['aiMessage'] as String?,
    );
  }

  TodaySummary copyWith({
    int? consumedCalories,
    int? burnedCalories,
    int? targetCalories,
    int? proteinG,
    int? targetProteinG,
    int? carbG,
    int? targetCarbG,
    int? fatG,
    int? targetFatG,
    int? fiberG,
    int? targetFiberG,
    int? sugarG,
    int? targetSugarG,
    int? sodiumMg,
    int? targetSodiumMg,
    double? healthScore,
    double? energyVitality,
    double? satietyVitality,
    double? recoveryVitality,
    double? fluidBalanceVitality,
    int? streakDays,
    double? currentWeightKg,
    double? targetWeightKg,
    String? aiMessage,
  }) {
    return TodaySummary(
      consumedCalories: consumedCalories ?? this.consumedCalories,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      targetCalories: targetCalories ?? this.targetCalories,
      proteinG: proteinG ?? this.proteinG,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      carbG: carbG ?? this.carbG,
      targetCarbG: targetCarbG ?? this.targetCarbG,
      fatG: fatG ?? this.fatG,
      targetFatG: targetFatG ?? this.targetFatG,
      fiberG: fiberG ?? this.fiberG,
      targetFiberG: targetFiberG ?? this.targetFiberG,
      sugarG: sugarG ?? this.sugarG,
      targetSugarG: targetSugarG ?? this.targetSugarG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      targetSodiumMg: targetSodiumMg ?? this.targetSodiumMg,
      healthScore: healthScore ?? this.healthScore,
      energyVitality: energyVitality ?? this.energyVitality,
      satietyVitality: satietyVitality ?? this.satietyVitality,
      recoveryVitality: recoveryVitality ?? this.recoveryVitality,
      fluidBalanceVitality:
          fluidBalanceVitality ?? this.fluidBalanceVitality,
      streakDays: streakDays ?? this.streakDays,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      aiMessage: aiMessage ?? this.aiMessage,
    );
  }
}

class DiaryEntry {
  final String id;
  final String name;
  final int calories;
  final int proteinG;
  final int carbG;
  final int fatG;
  final int fiberG;
  final int sugarG;
  final int sodiumMg;
  final String mealType;
  final String? imageUrl;
  final DateTime? time;

  DiaryEntry({
    required this.id,
    required this.name,
    this.calories = 0,
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
    required this.mealType,
    this.imageUrl,
    this.time,
  });

  int get mealOrder {
    switch (mealType) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      case 'snack':
        return 3;
      default:
        return 4;
    }
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String? ?? '',
      name: json['mon_chinh'] as String? ??
          json['name'] as String? ??
          json['food_name'] as String? ??
          '',
      calories: (json['total_calo'] as num?)?.toInt() ??
          (json['calories'] as num?)?.toInt() ??
          0,
      proteinG: (json['total_protein'] as num?)?.toInt() ??
          (json['protein'] as num?)?.toInt() ??
          (json['proteinG'] as num?)?.toInt() ??
          0,
      carbG: (json['total_carb'] as num?)?.toInt() ??
          (json['carbs'] as num?)?.toInt() ??
          (json['carbG'] as num?)?.toInt() ??
          0,
      fatG: (json['total_fat'] as num?)?.toInt() ??
          (json['fat'] as num?)?.toInt() ??
          (json['fatG'] as num?)?.toInt() ??
          0,
      fiberG: (json['total_fiber'] as num?)?.toInt() ??
          (json['fiber'] as num?)?.toInt() ??
          (json['fiberG'] as num?)?.toInt() ??
          0,
      sugarG: (json['total_sugar'] as num?)?.toInt() ??
          (json['sugar'] as num?)?.toInt() ??
          (json['sugarG'] as num?)?.toInt() ??
          0,
      sodiumMg: (json['total_sodium'] as num?)?.toInt() ??
          (json['sodium'] as num?)?.toInt() ??
          (json['sodiumMg'] as num?)?.toInt() ??
          0,
      mealType: json['mealType'] as String? ??
          json['meal_type'] as String? ??
          'snack',
      imageUrl: ApiConfig.resolveMediaUrl(
        json['thumbnail_url'] ?? json['image_url'] ?? json['imageUrl'],
      ),
      time: parseApiDateTime(json['created_at'] ?? json['time']),
    );
  }
}
