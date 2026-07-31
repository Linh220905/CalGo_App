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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as String?) ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatar: (json['avatar_url'] as String?) ?? (json['avatar'] as String?),
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      totalScans: (json['total_scans'] as num?)?.toInt() ??
          (json['totalScans'] as num?)?.toInt() ??
          0,
      isAdmin:
          (json['is_admin'] as bool?) ?? (json['isAdmin'] as bool?) ?? false,
      isDev: (json['is_dev'] as bool?) ?? (json['isDev'] as bool?) ?? false,
      hasCompletedOnboarding: (json['has_completed_onboarding'] as bool?) ??
          (json['hasCompletedOnboarding'] as bool?) ??
          false,
      dailyCalorieTarget: (json['daily_calorie_target'] as num?)?.toDouble() ??
          (json['dailyCalorieTarget'] as num?)?.toDouble() ??
          2000,
      subscriptionTier: (json['subscription_tier'] as String?) ??
          (json['subscriptionTier'] as String?),
    );
  }
}
