import '../models/gamification.dart';
import 'api_service.dart';

class GamificationApiService {
  final ApiService _api;

  GamificationApiService(this._api);

  Future<GamificationStatus> getStatus() async {
    final response = await _api.get('/gamification/status');
    return GamificationStatus.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Achievement>> getAchievements() async {
    final response = await _api.get('/gamification/achievements');
    final items = response is Map ? response['achievements'] : null;
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) => Achievement.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<WeeklyStats> getWeeklyStats() async {
    final response = await _api.get('/stats/7d');
    return WeeklyStats.fromJson(response as Map<String, dynamic>);
  }

  Future<MonthlyStats> getMonthlyStats() async {
    final response = await _api.get('/stats/30d');
    return MonthlyStats.fromJson(response as Map<String, dynamic>);
  }

  Future<GoalForecast> getForecast() async {
    final response = await _api.get('/stats/forecast');
    return GoalForecast.fromJson(response as Map<String, dynamic>);
  }

  Future<DailyRecap> getTodayRecap() async {
    final response = await _api.get('/recap/today');
    return DailyRecap.fromJson(response as Map<String, dynamic>);
  }

  Future<int> finishRecap(String dateKey) async {
    final response = await _api.post(
      '/recap/finish?date_key=${Uri.encodeQueryComponent(dateKey)}',
    );
    return response is Map ? (response['exp_earned'] as num?)?.toInt() ?? 0 : 0;
  }
}
