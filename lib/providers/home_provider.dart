import 'package:flutter/foundation.dart';
import '../models/home_data.dart';
import '../services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _service;

  TodaySummary _summary = TodaySummary();
  List<DiaryEntry> _entries = [];
  DateTime _selectedDate = DateTime.now();
  bool _loadingSummary = false;
  bool _loadingDiary = false;
  bool _hasLoaded = false;
  String? _error;
  int _loadGeneration = 0;

  static const _mealIcons = {
    'breakfast': '🌅',
    'lunch': '☀️',
    'dinner': '🌙',
    'snack': '🍪',
  };

  HomeProvider(this._service);

  TodaySummary get summary => _summary;
  List<DiaryEntry> get entries => _entries;
  DateTime get selectedDate => _selectedDate;
  bool get loadingSummary => _loadingSummary;
  bool get loadingDiary => _loadingDiary;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  int get remainingCalories => _summary.remainingCalories;

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Chào buổi sáng';
    if (h < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String get aiCoachMessage {
    if (_summary.aiMessage != null) return _summary.aiMessage!;
    final rem = _summary.remainingCalories;
    if (rem < 200) return 'Sắp đạt mục tiêu rồi! Cố lên!';
    if (rem > 1000) {
      return 'Hôm nay còn nhiều năng lượng. Ăn uống lành mạnh nhé!';
    }
    return 'Hãy duy trì đà này nhé!';
  }

  List<DiaryEntry> getMealsByType(String type) =>
      _entries.where((e) => e.mealType == type).toList();

  bool hasMealType(String type) => _entries.any((e) => e.mealType == type);

  void invalidateCache() {
    _service.invalidateCache();
  }

  Future<void> loadToday({bool forceRefresh = false}) async {
    final loadGeneration = ++_loadGeneration;
    if (forceRefresh) {
      _service.invalidateCache();
    }
    _loadingSummary = true;
    _loadingDiary = true;
    _error = null;
    notifyListeners();

    final date = '${_selectedDate.year.toString().padLeft(4, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';
    try {
      final dayData = await _service.getDayData(
        date,
        forceRefresh: forceRefresh,
      );
      if (loadGeneration != _loadGeneration) return;
      _summary = dayData.summary;
      _entries = dayData.meals;
    } catch (e) {
      if (loadGeneration != _loadGeneration) return;
      _error = 'Không thể tải dữ liệu';
    }
    if (loadGeneration != _loadGeneration) return;
    _loadingSummary = false;
    _loadingDiary = false;
    _hasLoaded = true;
    notifyListeners();
  }

  void removeEntry(String id) {
    DiaryEntry? removed;
    for (final entry in _entries) {
      if (entry.id == id) {
        removed = entry;
        break;
      }
    }
    _entries.removeWhere((entry) => entry.id == id);
    _service.invalidateCache();
    if (removed != null) {
      _summary = TodaySummary(
        consumedCalories: (_summary.consumedCalories - removed.calories)
            .clamp(0, 100000)
            .toInt(),
        burnedCalories: _summary.burnedCalories,
        targetCalories: _summary.targetCalories,
        proteinG:
            (_summary.proteinG - removed.proteinG).clamp(0, 100000).toInt(),
        targetProteinG: _summary.targetProteinG,
        carbG: (_summary.carbG - removed.carbG).clamp(0, 100000).toInt(),
        targetCarbG: _summary.targetCarbG,
        fatG: (_summary.fatG - removed.fatG).clamp(0, 100000).toInt(),
        targetFatG: _summary.targetFatG,
        streakDays: _summary.streakDays,
        currentWeightKg: _summary.currentWeightKg,
        targetWeightKg: _summary.targetWeightKg,
        aiMessage: _summary.aiMessage,
      );
    }
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadToday();
  }

  String mealIcon(String type) => _mealIcons[type] ?? '🍽️';
}
