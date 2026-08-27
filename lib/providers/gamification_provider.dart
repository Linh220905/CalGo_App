import 'package:flutter/foundation.dart';
import '../models/gamification.dart';
import '../services/api_service.dart';
import '../services/gamification_service.dart';

class GamificationProvider extends ChangeNotifier {
  final GamificationApiService _service;

  GamificationStatus _status = GamificationStatus.empty();
  List<Achievement> _achievements = const [];
  WeeklyStats? _weekly;
  MonthlyStats? _monthly;
  GoalForecast? _forecast;
  DailyRecap? _recap;
  bool _loading = false;
  bool _recapLoading = false;
  bool _recapNotReady = false;
  String? _error;
  int _pendingScanExp = 0;
  int _refreshGeneration = 0;

  GamificationProvider(ApiService api) : _service = GamificationApiService(api);

  GamificationStatus get status => _status;
  List<Achievement> get achievements => _achievements;
  WeeklyStats? get weekly => _weekly;
  MonthlyStats? get monthly => _monthly;
  GoalForecast? get forecast => _forecast;
  DailyRecap? get recap => _recap;
  bool get loading => _loading;
  bool get recapLoading => _recapLoading;
  bool get recapNotReady => _recapNotReady;
  String? get error => _error;
  bool get hasStats => _weekly != null && _monthly != null;

  Future<void> refresh() async {
    final generation = ++_refreshGeneration;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final values = await Future.wait<dynamic>([
        _service.getStatus(),
        _service.getAchievements(),
        _service.getWeeklyStats(),
        _service.getMonthlyStats(),
        _service.getForecast(),
      ]);
      if (generation != _refreshGeneration) return;
      _status = values[0] as GamificationStatus;
      _achievements = values[1] as List<Achievement>;
      _weekly = values[2] as WeeklyStats;
      _monthly = values[3] as MonthlyStats;
      _forecast = values[4] as GoalForecast;
    } catch (_) {
      if (generation == _refreshGeneration) _error = 'dataLoadFailed';
    } finally {
      if (generation == _refreshGeneration) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshRecap() async {
    if (_recapLoading || !_isAfterTenPm()) return;
    _recapLoading = true;
    _recapNotReady = false;
    notifyListeners();
    try {
      _recap = await _service.getTodayRecap();
    } on ApiException catch (error) {
      if (error.statusCode == 425 || error.message.contains('not_ready')) {
        _recapNotReady = true;
      }
    } catch (_) {
      // Recap is optional; Home remains usable if the AI endpoint is down.
    } finally {
      _recapLoading = false;
      notifyListeners();
    }
  }

  void registerScanReward(int exp) {
    if (exp > 0) _pendingScanExp += exp;
    notifyListeners();
  }

  int takePendingScanReward() {
    final reward = _pendingScanExp;
    _pendingScanExp = 0;
    return reward;
  }

  Future<int> finishRecap() async {
    final current = _recap;
    if (current == null || current.isFinished) return 0;
    final exp = await _service.finishRecap(current.dateKey);
    _recap = DailyRecap(
      dateKey: current.dateKey,
      totalCalo: current.totalCalo,
      targetCalo: current.targetCalo,
      proteinPct: current.proteinPct,
      carbPct: current.carbPct,
      fatPct: current.fatPct,
      mealCount: current.mealCount,
      waterLiters: current.waterLiters,
      isFinished: true,
      expEarned: exp,
      aiComment: current.aiComment,
      tomorrowTip: current.tomorrowTip,
      unlockedBadges: current.unlockedBadges,
    );
    await refresh();
    return exp;
  }

  bool _isAfterTenPm() => DateTime.now().hour >= 22;
}
