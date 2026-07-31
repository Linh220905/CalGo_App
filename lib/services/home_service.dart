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

  static const _cacheLifetime = Duration(seconds: 30);

  void invalidateCache() {
    _cachedEntries = null;
    _cachedUser = null;
    _cacheTime = null;
  }

  Future<HomeDayData> getDayData(
    String date, {
    bool forceRefresh = false,
  }) async {
    final cacheFresh = _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheLifetime &&
        _cachedEntries != null &&
        _cachedUser != null;

    if (forceRefresh || !cacheFresh) {
      final responses = await Future.wait([
        _api.get('/scan/history?limit=100&offset=0'),
        _api.get('/users/me'),
      ]);
      final history = responses[0] as List<dynamic>;
      _cachedEntries = history
          .map((item) => DiaryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      _cachedUser = Map<String, dynamic>.from(
        responses[1] as Map<String, dynamic>,
      );
      _cacheTime = DateTime.now();
    }

    final allEntries = _cachedEntries!;
    final user = _cachedUser!;
    final meals =
        allEntries.where((entry) => _dateKey(entry.time) == date).toList();

    var calories = 0;
    var protein = 0;
    var carbs = 0;
    var fat = 0;
    for (final meal in meals) {
      calories += meal.calories;
      protein += meal.proteinG;
      carbs += meal.carbG;
      fat += meal.fatG;
    }

    final summary = TodaySummary.fromJson({
      'total_calo': calories,
      'total_protein': protein,
      'total_carb': carbs,
      'total_fat': fat,
      'target_calories': user['daily_calorie_target'],
      'target_protein': user['protein_grams'],
      'target_carb': user['carbs_grams'],
      'target_fat': user['fat_grams'],
      'current_weight_kg': user['current_weight_kg'],
      'target_weight_kg': user['target_weight_kg'],
      'streak': _calculateStreak(allEntries),
    });

    return HomeDayData(summary: summary, meals: meals);
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
