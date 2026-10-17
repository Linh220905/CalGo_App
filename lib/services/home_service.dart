import 'api_service.dart';
import '../models/home_data.dart';

class HomeDayData {
  final TodaySummary summary;
  final List<DiaryEntry> meals;

  const HomeDayData({required this.summary, required this.meals});
}

class HomeService {
  final ApiService _api;
  HomeService(this._api);

  List<DiaryEntry>? _cachedEntries;
  Map<String, dynamic>? _cachedUser;
  DateTime? _cacheTime;
  int? _cacheAuthScope;

  static const _cacheLifetime = Duration(seconds: 30);

  void invalidateCache() {
    _cachedEntries = null;
    _cachedUser = null;
    _cacheTime = null;
    _cacheAuthScope = null;
  }

  Future<HomeDayData> getDayData(
    String date, {
    bool forceRefresh = false,
  }) async {
    final cacheFresh =
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheLifetime &&
        _cachedEntries != null &&
        _cachedUser != null &&
        _cacheAuthScope == _api.authScope;

    if (forceRefresh || !cacheFresh) {
      final responses = await Future.wait([
        _getAllHistory(),
        _api.get('/users/me', caller: 'HomeService.getDayData'),
      ]);
      final history = responses[0] as List<dynamic>;
      _cachedEntries = history
          .map((item) => DiaryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      _cachedUser = Map<String, dynamic>.from(
        responses[1] as Map<String, dynamic>,
      );
      _cacheTime = DateTime.now();
      _cacheAuthScope = _api.authScope;
    }

    final allEntries = _cachedEntries!;
    final user = _cachedUser!;
    final meals = allEntries
        .where((entry) => _dateKey(entry.time) == date)
        .toList();

    var calories = 0;
    var protein = 0;
    var carbs = 0;
    var fat = 0;
    var fiber = 0;
    var sugar = 0;
    var sodium = 0;
    for (final meal in meals) {
      calories += meal.calories;
      protein += meal.proteinG;
      carbs += meal.carbG;
      fat += meal.fatG;
      fiber += meal.fiberG;
      sugar += meal.sugarG;
      sodium += meal.sodiumMg;
    }

    final targetCalories = (user['daily_calorie_target'] as num?)?.toInt() ?? 2000;
    final targetProtein = (user['protein_grams'] as num?)?.toInt() ?? 130;
    final targetCarb = (user['carbs_grams'] as num?)?.toInt() ?? 200;
    final targetFat = (user['fat_grams'] as num?)?.toInt() ?? 60;

    // Scientific targets based on user's daily calorie target & WHO / USDA guidelines
    final targetFiber = (user['fiber_grams'] as num?)?.toInt() ??
        ((targetCalories / 1000.0) * 14.0).round().clamp(20, 45);
    final targetSugar = (user['sugar_grams'] as num?)?.toInt() ??
        ((targetCalories * 0.10) / 4.0).round().clamp(25, 50);
    final targetSodium = (user['sodium_mg'] as num?)?.toInt() ?? 2000;

    // CalGo progress indicators; these are not clinical or Nutri-Score metrics.
    final double healthScore;
    final double energyVitality;
    final double satietyVitality;
    final double recoveryVitality;
    final double fluidBalanceVitality;

    if (calories == 0 || meals.isEmpty) {
      healthScore = 0.0;
      energyVitality = 0.0;
      satietyVitality = 0.0;
      recoveryVitality = 0.0;
      fluidBalanceVitality = 0.0;
    } else {
      // 1. CalGo nutrition score (0.0 - 10.0), based on logged nutrients.
      // Balance components: Protein quality (35%), Fiber quality (35%), Sugar control (30%)
      final proteinRatio = targetProtein > 0 ? (protein / targetProtein).clamp(0.0, 1.2) : 0.0;
      final fiberRatio = targetFiber > 0 ? (fiber / targetFiber).clamp(0.0, 1.2) : 0.0;
      final sugarPenalty = targetSugar > 0 ? (sugar / targetSugar).clamp(0.0, 2.0) : 0.0;

      final proteinScore = (proteinRatio / 1.0).clamp(0.0, 1.0) * 3.5;
      final fiberScore = (fiberRatio / 1.0).clamp(0.0, 1.0) * 3.5;
      final sugarScore = (1.0 - (sugarPenalty - 1.0).clamp(0.0, 1.0)) * 3.0;
      healthScore = (proteinScore + fiberScore + sugarScore).clamp(0.0, 10.0);

      // 2. Calorie and carb target progress (0 - 100%).
      final caloProgress = targetCalories > 0 ? (calories / targetCalories).clamp(0.0, 1.2) : 0.0;
      final carbProgress = targetCarb > 0 ? (carbs / targetCarb).clamp(0.0, 1.2) : 0.0;
      final sugarExcess = targetSugar > 0 && sugar > targetSugar ? ((sugar - targetSugar) / targetSugar).clamp(0.0, 1.0) : 0.0;
      final rawEnergy = (caloProgress * 50.0 + carbProgress * 50.0) * (1.0 - (sugarExcess * 0.3));
      energyVitality = rawEnergy.clamp(0.0, 100.0);

      // 3. Fiber and protein target progress (0.0 - 10.0).
      final proteinSatiety = (proteinRatio * 5.0).clamp(0.0, 5.0);
      final fiberSatiety = (fiberRatio * 5.0).clamp(0.0, 5.0);
      satietyVitality = (proteinSatiety + fiberSatiety).clamp(0.0, 10.0);

      // 4. Protein and total-fat target balance (0 - 100%).
      final proteinRecovery = (proteinRatio * 70.0).clamp(0.0, 70.0);
      final fatBalance = targetFat > 0 ? (1.0 - ((fat - targetFat).abs() / targetFat).clamp(0.0, 1.0)) * 30.0 : 30.0;
      recoveryVitality = (proteinRecovery + fatBalance).clamp(0.0, 100.0);

      // 5. Sodium target comparison (0 - 100%).
      final sodiumExcessRatio = targetSodium > 0 ? (sodium / targetSodium) : 0.0;
      final sodiumScore = sodiumExcessRatio <= 1.0
          ? 100.0
          : (100.0 - ((sodiumExcessRatio - 1.0) * 70.0)).clamp(20.0, 100.0);
      fluidBalanceVitality = sodiumScore;
    }

    final summary = TodaySummary(
      consumedCalories: calories,
      proteinG: protein,
      carbG: carbs,
      fatG: fat,
      fiberG: fiber,
      sugarG: sugar,
      sodiumMg: sodium,
      targetCalories: targetCalories,
      targetProteinG: targetProtein,
      targetCarbG: targetCarb,
      targetFatG: targetFat,
      targetFiberG: targetFiber,
      targetSugarG: targetSugar,
      targetSodiumMg: targetSodium,
      healthScore: healthScore,
      energyVitality: energyVitality,
      satietyVitality: satietyVitality,
      recoveryVitality: recoveryVitality,
      fluidBalanceVitality: fluidBalanceVitality,
      currentWeightKg: (user['current_weight_kg'] as num?)?.toDouble() ?? 0.0,
      targetWeightKg: (user['target_weight_kg'] as num?)?.toDouble() ?? 0.0,
      streakDays: _calculateStreak(allEntries),
    );

    return HomeDayData(summary: summary, meals: meals);
  }

  Future<List<dynamic>> _getAllHistory() async {
    const pageSize = 100;
    var offset = 0;
    final items = <dynamic>[];
    while (true) {
      final page = await _api.get(
        '/scan/history?limit=$pageSize&offset=$offset',
        caller: 'HomeService._getAllHistory',
      );
      if (page is! List) break;
      items.addAll(page);
      if (page.length < pageSize) break;
      offset += page.length;
    }
    return items;
  }

  String? _dateKey(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  int _calculateStreak(List<DiaryEntry> entries) {
    final dates = entries
        .map((entry) => _dateKey(entry.time))
        .whereType<String>()
        .toSet();
    var cursor = DateTime.now();
    // Keep yesterday's active streak visible until the current day ends.
    if (!dates.contains(_dateKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (dates.contains(
      '${cursor.year.toString().padLeft(4, '0')}-'
      '${cursor.month.toString().padLeft(2, '0')}-'
      '${cursor.day.toString().padLeft(2, '0')}',
    )) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}
