import '../config/app_build_config.dart';

class User {
  final String id;
  final String? email;
  final String? name;
  final String? avatar;
  final int credits;
  final int totalScans;
  final bool isAdmin;
  final bool isDev;
  final bool hasCompletedOnboarding;
  final double dailyCalorieTarget;
  final String? subscriptionTier;
  final String? gender;
  final int? age;
  final double? heightCm;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final String? activityLevel;
  final String? goal;
  final double? weeklyGoalKg;

  User({
    required this.id,
    this.email,
    this.name,
    this.avatar,
    this.credits = 0,
    this.totalScans = 0,
    this.isAdmin = false,
    this.isDev = false,
    this.hasCompletedOnboarding = false,
    this.dailyCalorieTarget = 2000,
    this.subscriptionTier,
    this.gender,
    this.age,
    this.heightCm,
    this.currentWeightKg,
    this.targetWeightKg,
    this.activityLevel,
    this.goal,
    this.weeklyGoalKg,
  });

  /// Testing builds keep Premium entitlement enabled for QA/API coverage, but
  /// hide Premium entry points from testers. Server-side test accounts should
  /// still be marked is_dev so protected API operations are also available.
  bool get hasPremiumAccess =>
      AppBuildConfig.premiumFreeForTesting || subscriptionTier != null || isDev;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as String?) ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatar: (json['avatar_url'] as String?) ?? (json['avatar'] as String?),
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      totalScans:
          (json['total_scans'] as num?)?.toInt() ??
          (json['totalScans'] as num?)?.toInt() ??
          0,
      isAdmin:
          (json['is_admin'] as bool?) ?? (json['isAdmin'] as bool?) ?? false,
      isDev: (json['is_dev'] as bool?) ?? (json['isDev'] as bool?) ?? false,
      hasCompletedOnboarding:
          (json['has_completed_onboarding'] as bool?) ??
          (json['hasCompletedOnboarding'] as bool?) ??
          false,
      dailyCalorieTarget:
          (json['daily_calorie_target'] as num?)?.toDouble() ??
          (json['dailyCalorieTarget'] as num?)?.toDouble() ??
          2000,
      subscriptionTier:
          (json['subscription_tier'] as String?) ??
          (json['subscriptionTier'] as String?),
      gender: json['gender'] as String?,
      age: (json['age'] as num?)?.toInt(),
      heightCm:
          (json['height_cm'] as num?)?.toDouble() ??
          (json['heightCm'] as num?)?.toDouble(),
      currentWeightKg:
          (json['current_weight_kg'] as num?)?.toDouble() ??
          (json['currentWeightKg'] as num?)?.toDouble(),
      targetWeightKg:
          (json['target_weight_kg'] as num?)?.toDouble() ??
          (json['targetWeightKg'] as num?)?.toDouble(),
      activityLevel:
          (json['activity_level'] as String?) ??
          (json['activityLevel'] as String?),
      goal: json['goal'] as String?,
      weeklyGoalKg:
          (json['weekly_goal_kg'] as num?)?.toDouble() ??
          (json['weeklyGoalKg'] as num?)?.toDouble(),
    );
  }
}
