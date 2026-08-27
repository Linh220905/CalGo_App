/// Gamification data models for CalGo.

class GamificationStatus {
  final int exp;
  final int level;
  final int expToNextLevel;
  final int expInCurrentLevel;
  final int streakDays;
  final int totalScans;
  final int scansToday;
  final double levelProgress; // 0.0 - 1.0

  const GamificationStatus({
    required this.exp,
    required this.level,
    required this.expToNextLevel,
    required this.expInCurrentLevel,
    required this.streakDays,
    required this.totalScans,
    required this.scansToday,
    required this.levelProgress,
  });

  factory GamificationStatus.empty() => const GamificationStatus(
        exp: 0,
        level: 1,
        expToNextLevel: 100,
        expInCurrentLevel: 0,
        streakDays: 0,
        totalScans: 0,
        scansToday: 0,
        levelProgress: 0.0,
      );

  factory GamificationStatus.fromJson(Map<String, dynamic> json) {
    return GamificationStatus(
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      expToNextLevel: (json['exp_to_next_level'] as num?)?.toInt() ??
          (json['next_level_exp'] as num?)?.toInt() ??
          100,
      expInCurrentLevel: (json['exp_in_current_level'] as num?)?.toInt() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ??
          (json['streak'] as num?)?.toInt() ??
          0,
      totalScans: (json['total_scans'] as num?)?.toInt() ?? 0,
      scansToday: (json['scans_today'] as num?)?.toInt() ?? 0,
      levelProgress: (json['level_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String levelTitle(int level) {
    const titles = [
      '', // placeholder index 0
      'Người mới bắt đầu',
      'Người theo dõi',
      'Người kiên trì',
      'Người có kỷ luật',
      'Người nhiệt huyết',
      'Người đam mê sức khỏe',
      'Chuyên gia dinh dưỡng',
      'Nhà vô địch',
      'Huyền thoại',
      'Master CalGo',
    ];
    if (level <= 0) return titles[1];
    if (level >= titles.length) return titles.last;
    return titles[level];
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji or asset name
  final String category; // streak, scan, goal, water
  final bool unlocked;
  final DateTime? unlockedAt;
  final int? progressCurrent;
  final int? progressTarget;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.unlocked,
    this.unlockedAt,
    this.progressCurrent,
    this.progressTarget,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏅',
      category: json['category'] as String? ?? 'scan',
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'] as String)
          : null,
      progressCurrent: (json['progress_current'] as num?)?.toInt(),
      progressTarget: (json['progress_target'] as num?)?.toInt(),
    );
  }

  double get progress {
    if (progressTarget == null || progressTarget == 0)
      return unlocked ? 1.0 : 0.0;
    return ((progressCurrent ?? 0) / progressTarget!).clamp(0.0, 1.0);
  }
}

class DailyRecap {
  final String dateKey;
  final int totalCalo;
  final int targetCalo;
  final double proteinPct;
  final double carbPct;
  final double fatPct;
  final int mealCount;
  final double waterLiters;
  final bool isFinished;
  final int expEarned;
  final String? aiComment;
  final String? tomorrowTip;
  final List<Achievement> unlockedBadges;

  const DailyRecap({
    required this.dateKey,
    required this.totalCalo,
    required this.targetCalo,
    required this.proteinPct,
    required this.carbPct,
    required this.fatPct,
    required this.mealCount,
    required this.waterLiters,
    required this.isFinished,
    required this.expEarned,
    this.aiComment,
    this.tomorrowTip,
    this.unlockedBadges = const [],
  });

  double get caloPct =>
      targetCalo > 0 ? (totalCalo / targetCalo).clamp(0.0, 1.5) : 0.0;
  int get caloPercentDisplay => (caloPct * 100).round();

  factory DailyRecap.fromJson(Map<String, dynamic> json) {
    final badges = (json['unlocked_badges'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((b) => Achievement.fromJson(b))
        .toList();
    return DailyRecap(
      dateKey: json['date_key'] as String? ?? '',
      totalCalo: (json['total_calo'] as num?)?.toInt() ?? 0,
      targetCalo: (json['target_calo'] as num?)?.toInt() ?? 2000,
      proteinPct: (json['protein_pct'] as num?)?.toDouble() ?? 0,
      carbPct: (json['carb_pct'] as num?)?.toDouble() ?? 0,
      fatPct: (json['fat_pct'] as num?)?.toDouble() ?? 0,
      mealCount: (json['meal_count'] as num?)?.toInt() ?? 0,
      waterLiters: (json['water_liters'] as num?)?.toDouble() ?? 0,
      isFinished: json['is_finished'] as bool? ?? false,
      expEarned: (json['exp_earned'] as num?)?.toInt() ?? 0,
      aiComment: json['ai_comment'] as String?,
      tomorrowTip: json['tomorrow_tip'] as String?,
      unlockedBadges: badges,
    );
  }
}

class WeeklyStats {
  final double avgCalo;
  final double avgProtein;
  final double avgCarb;
  final double avgFat;
  final int daysLogged;
  final int streakDays;
  final List<DayCaloriePoint> dailyPoints;

  const WeeklyStats({
    required this.avgCalo,
    required this.avgProtein,
    required this.avgCarb,
    required this.avgFat,
    required this.daysLogged,
    required this.streakDays,
    required this.dailyPoints,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['daily_points'] ?? json['daily_breakdown'];
    final points = (rawPoints is List ? rawPoints : const <dynamic>[])
        .whereType<Map>()
        .map((p) => Map<String, dynamic>.from(p))
        .map((p) => DayCaloriePoint.fromJson(p))
        .toList();
    return WeeklyStats(
      avgCalo: (json['avg_calo'] as num?)?.toDouble() ??
          (json['avg_calo_daily'] as num?)?.toDouble() ??
          0,
      avgProtein: (json['avg_protein'] as num?)?.toDouble() ??
          (json['avg_protein_daily'] as num?)?.toDouble() ??
          0,
      avgCarb: (json['avg_carb'] as num?)?.toDouble() ?? 0,
      avgFat: (json['avg_fat'] as num?)?.toDouble() ?? 0,
      daysLogged: (json['days_logged'] as num?)?.toInt() ?? 0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      dailyPoints: points,
    );
  }
}

class DayCaloriePoint {
  final String dateKey;
  final int calo;
  final int target;
  final bool hasLog;

  const DayCaloriePoint({
    required this.dateKey,
    required this.calo,
    required this.target,
    required this.hasLog,
  });

  double get pct => target > 0 ? (calo / target).clamp(0.0, 1.4) : 0.0;

  factory DayCaloriePoint.fromJson(Map<String, dynamic> json) {
    return DayCaloriePoint(
      dateKey: (json['date_key'] ?? json['date'] ?? '').toString(),
      calo: (json['calo'] as num?)?.toInt() ??
          (json['calories'] as num?)?.toInt() ??
          0,
      target: (json['target'] as num?)?.toInt() ?? 2000,
      hasLog: json['has_log'] as bool? ?? json['logged'] as bool? ?? false,
    );
  }
}

class MonthlyStats {
  final double adherencePercent;
  final int loggedDays;
  final int totalDays;
  final int streakDays;
  final List<DayLogPoint> days;

  const MonthlyStats({
    required this.adherencePercent,
    required this.loggedDays,
    required this.totalDays,
    required this.streakDays,
    required this.days,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    final raw = json['matrix'];
    return MonthlyStats(
      adherencePercent: (json['adherence_pct'] as num?)?.toDouble() ?? 0,
      loggedDays: (json['logged_days_count'] as num?)?.toInt() ?? 0,
      totalDays: (json['total_days'] as num?)?.toInt() ?? 30,
      streakDays: (json['streak'] as num?)?.toInt() ?? 0,
      days: (raw is List ? raw : const <dynamic>[])
          .whereType<Map>()
          .map((item) => DayLogPoint.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class DayLogPoint {
  final String dateKey;
  final bool logged;
  final int scanCount;

  const DayLogPoint({
    required this.dateKey,
    required this.logged,
    this.scanCount = 0,
  });

  factory DayLogPoint.fromJson(Map<String, dynamic> json) => DayLogPoint(
        dateKey: (json['date'] ?? json['date_key'] ?? '').toString(),
        logged: json['logged'] as bool? ?? json['has_log'] as bool? ?? false,
        scanCount: (json['scan_count'] as num?)?.toInt() ?? 0,
      );
}

class GoalForecast {
  final double currentWeight;
  final double targetWeight;
  final double estimatedWeeks;
  final String display;

  const GoalForecast({
    required this.currentWeight,
    required this.targetWeight,
    required this.estimatedWeeks,
    required this.display,
  });

  factory GoalForecast.fromJson(Map<String, dynamic> json) => GoalForecast(
        currentWeight: (json['current_weight_kg'] as num?)?.toDouble() ?? 0,
        targetWeight: (json['target_weight_kg'] as num?)?.toDouble() ?? 0,
        estimatedWeeks: (json['estimated_weeks'] as num?)?.toDouble() ?? 0,
        display: (json['estimated_weeks_display'] ?? '').toString(),
      );
}
