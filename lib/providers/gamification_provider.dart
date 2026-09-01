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
  String? _statusError;
  String? _achievementsError;
  String? _weeklyError;
  String? _monthlyError;
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
  String? get statusError => _statusError;
  String? get achievementsError => _achievementsError;
  String? get weeklyError => _weeklyError;
  String? get monthlyError => _monthlyError;
  bool get hasStatus => _statusError == null && _statusLoaded;
  bool get hasAchievements => _achievementsError == null && _achievementsLoaded;
  bool get hasWeekly => _weekly != null;
  bool get hasMonthly => _monthly != null;
  bool get hasStats => _weekly != null && _monthly != null;

  bool _statusLoaded = false;
  bool _achievementsLoaded = false;

  Future<void> refresh() async {
    final generation = ++_refreshGeneration;
    _loading = true;
    _error = null;
    _statusError = null;
    _achievementsError = null;
    _weeklyError = null;
    _monthlyError = null;
    _statusLoaded = false;
    _achievementsLoaded = false;
    notifyListeners();
    final values = await Future.wait<Object?>([
      _tryLoad(_service.getStatus),
      _tryLoad(_service.getAchievements),
      _tryLoad(_service.getWeeklyStats),
      _tryLoad(_service.getMonthlyStats),
    ]);
    if (generation != _refreshGeneration) return;

    if (values[0] is GamificationStatus) {
      _status = values[0] as GamificationStatus;
      _statusLoaded = true;
    } else {
      _statusError = 'dataLoadFailed';
    }
    if (values[1] is List<Achievement>) {
      _achievements = values[1] as List<Achievement>;
      _achievementsLoaded = true;
    } else {
      _achievementsError = 'dataLoadFailed';
    }
    if (values[2] is WeeklyStats) {
      _weekly = values[2] as WeeklyStats;
    } else {
      _weeklyError = 'dataLoadFailed';
    }
    if (values[3] is MonthlyStats) {
      _monthly = values[3] as MonthlyStats;
    } else {
      _monthlyError = 'dataLoadFailed';
    }
    _error =
        (_statusError != null ||
            _achievementsError != null ||
            _weeklyError != null ||
            _monthlyError != null)
        ? 'dataLoadFailed'
        : null;
    _loading = false;
    notifyListeners();
  }

  Future<T?> _tryLoad<T>(Future<T> Function() loader) async {
    try {
      return await loader();
    } catch (_) {
      return null;
    }
  }

  Future<WeeklyStats> fetchWeeklyStats({int weeksAgo = 0}) =>
      _service.getWeeklyStats(weeksAgo: weeksAgo);

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
