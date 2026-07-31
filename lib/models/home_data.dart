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
    this.streakDays = 0,
    this.currentWeightKg = 0,
    this.targetWeightKg = 0,
    this.aiMessage,
  });

  int get remainingCalories =>
      (targetCalories - consumedCalories + burnedCalories)
          .clamp(0, targetCalories);
  double get caloriesProgress =>
      targetCalories > 0 ? (consumedCalories / targetCalories).clamp(0, 1) : 0;
  double get proteinProgress =>
      targetProteinG > 0 ? (proteinG / targetProteinG).clamp(0, 1) : 0;
  double get carbProgress =>
      targetCarbG > 0 ? (carbG / targetCarbG).clamp(0, 1) : 0;
  double get fatProgress =>
      targetFatG > 0 ? (fatG / targetFatG).clamp(0, 1) : 0;

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
}

class DiaryEntry {
  final String id;
  final String name;
  final int calories;
  final int proteinG;
  final int carbG;
  final int fatG;
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
    required this.mealType,
    this.imageUrl,
    this.time,
  });

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Bữa sáng';
      case 'lunch':
        return 'Bữa trưa';
      case 'dinner':
        return 'Bữa tối';
      case 'snack':
        return 'Bữa phụ';
      default:
        return mealType;
    }
  }

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
