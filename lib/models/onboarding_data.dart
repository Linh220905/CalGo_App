enum Gender { male, female, other }

enum GoalType { lose, gain, maintain }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum DietType { normal, clean, keto, lowCarb, vegetarian, vegan }

class OnboardingData {
  static const int defaultAge = 25;
  static const double defaultHeightCm = 170;
  static const double defaultWeightKg = 72;
  static const double defaultWeeklyGoalKg = 0.5;
  static const int defaultTargetWeeks = 12;

  String? name;
  Gender? gender;
  int? age;
  double? heightCm;
  double? weightKg;
  GoalType? goalType;
  double? targetWeightKg;
  int? targetWeeks;
  double? lossPerWeekKg;
  ActivityLevel? activityLevel;
  List<String> sports;
  DietType? dietType;
  String? allergies;
  String? referralSource;

  // New onboarding fields
  List<String> pains;
  String? motivation;
  String? habitPattern;
  String? biggestChallenge;
  bool? likedApp;
  String? accountMethod;

  OnboardingData({
    this.name,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.goalType,
    this.targetWeightKg,
    this.targetWeeks,
    this.lossPerWeekKg,
    this.activityLevel,
    this.sports = const [],
    this.dietType,
    this.allergies,
    this.referralSource,
    this.pains = const [],
    this.motivation,
    this.habitPattern,
    this.biggestChallenge,
    this.likedApp,
    this.accountMethod,
  });

  double get bmi {
    if (heightCm == null ||
        heightCm! <= 0 ||
        weightKg == null ||
        weightKg! <= 0) {
      return 0;
    }
    final h = heightCm! / 100;
    return weightKg! / (h * h);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Gầy';
    if (b < 23) return 'Bình thường';
    if (b < 27.5) return 'Hơi thừa cân';
    return 'Béo phì';
  }

  /// BMR — Mifflin-St Jeor
  double get bmr {
    if (weightKg == null ||
        weightKg! <= 0 ||
        heightCm == null ||
        heightCm! <= 0 ||
        age == null ||
        age! <= 0 ||
        gender == null) {
      return 0;
    }
    final s = switch (gender!) {
      Gender.male => 5,
      Gender.female => -161,
      // Use the midpoint of the two Mifflin-St Jeor constants when the
      // user does not identify as male or female.
      Gender.other => -78,
    };
    return (10 * weightKg!) + (6.25 * heightCm!) - (5 * age!) + s;
  }

  /// TDEE
  double get tdee {
    final b = bmr;
    if (b == 0 || activityLevel == null) return 0;
    return b * _activityFactor;
  }

  double get _activityFactor {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
      default:
        return 1.2;
    }
  }

  double get targetCaloriesPerDay {
    final t = tdee;
    if (t == 0) return 0;
    final weeklyRate =
        (lossPerWeekKg ?? defaultWeeklyGoalKg).abs().clamp(0.0, 1.5);
    final adjustment = (weeklyRate * 7700 / 7).clamp(0.0, 1100.0);
    final rawTarget = switch (goalType) {
      GoalType.lose => t - adjustment,
      GoalType.gain => t + adjustment,
      GoalType.maintain || null => t,
    };
    final minimum = switch (gender) {
      Gender.male => 1500.0,
      Gender.female => 1200.0,
      Gender.other || null => 1350.0,
    };
    return rawTarget < minimum ? minimum : rawTarget;
  }

  double get targetProteinG {
    final calories = targetCaloriesPerDay;
    if (calories <= 0 || weightKg == null || weightKg! <= 0) return 0;
    // Keep protein useful without allowing it to consume the entire calorie
    // budget for users with a high body weight and a low calorie target.
    final byWeight = 2 * weightKg!;
    final maxByCalories = (calories * 0.35) / 4;
    return byWeight < maxByCalories ? byWeight : maxByCalories;
  }

  double get targetFatG {
    final calories = targetCaloriesPerDay;
    return calories > 0 ? (calories * 0.25) / 9 : 0;
  }

  double get targetCarbG {
    final calories = targetCaloriesPerDay;
    if (calories <= 0) return 0;
    final remaining = calories - (targetProteinG * 4) - (targetFatG * 9);
    return remaining > 0 ? remaining / 4 : 0;
  }

  String get activityApiValue => switch (activityLevel) {
        ActivityLevel.sedentary => 'sedentary',
        ActivityLevel.light => 'lightly_active',
        ActivityLevel.moderate => 'moderately_active',
        ActivityLevel.active => 'very_active',
        ActivityLevel.veryActive => 'extremely_active',
        null => 'moderately_active',
      };

  /// Ensures the calculation uses the same values that the picker screens
  /// display when the user accepts their defaults without moving the ruler.
  void applyDisplayedDefaults() {
    age ??= defaultAge;
    heightCm ??= defaultHeightCm;
    weightKg ??= defaultWeightKg;
    gender ??= Gender.other;
    goalType ??= GoalType.maintain;
    activityLevel ??= ActivityLevel.moderate;
    lossPerWeekKg ??= defaultWeeklyGoalKg;
    targetWeeks ??= defaultTargetWeeks;

    if (goalType == GoalType.maintain) {
      targetWeightKg = weightKg;
    } else {
      targetWeightKg ??= weightKg;
    }
  }

  /// Weight projection: ~0.5kg/month gain at current habits
  double? get weightInOneYearNoChange {
    if (weightKg == null) return null;
    return weightKg! + 6.0;
  }

  void clear() {
    name = null;
    gender = null;
    age = null;
    heightCm = null;
    weightKg = null;
    goalType = null;
    targetWeightKg = null;
    targetWeeks = null;
    lossPerWeekKg = null;
    activityLevel = null;
    sports = [];
    dietType = null;
    allergies = null;
    referralSource = null;
    pains = [];
    motivation = null;
    habitPattern = null;
    biggestChallenge = null;
    likedApp = null;
    accountMethod = null;
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (gender != null) 'gender': gender!.name,
        if (age != null) 'age': age,
        if (heightCm != null) 'heightCm': heightCm,
        if (weightKg != null) 'weightKg': weightKg,
        if (goalType != null) 'goalType': goalType!.name,
        if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
        if (targetWeeks != null) 'targetWeeks': targetWeeks,
        if (lossPerWeekKg != null) 'lossPerWeekKg': lossPerWeekKg,
        if (activityLevel != null) 'activityLevel': activityLevel!.name,
        if (sports.isNotEmpty) 'sports': sports,
        if (dietType != null) 'dietType': dietType!.name,
        if (allergies != null && allergies!.isNotEmpty) 'allergies': allergies,
        if (referralSource != null) 'referralSource': referralSource,
        if (pains.isNotEmpty) 'pains': pains,
        if (motivation != null) 'motivation': motivation,
        if (habitPattern != null) 'habitPattern': habitPattern,
        if (biggestChallenge != null) 'biggestChallenge': biggestChallenge,
        if (likedApp != null) 'likedApp': likedApp,
        if (accountMethod != null) 'accountMethod': accountMethod,
      };
}
