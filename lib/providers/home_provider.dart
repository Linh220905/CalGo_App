import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/home_data.dart';
import '../models/meal_guidance.dart';
import '../services/home_service.dart';
import '../services/meal_guidance_service.dart';
import '../l10n/generated/app_localizations.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _service;
  final MealGuidanceService _mealGuidanceService;

  TodaySummary _summary = TodaySummary();
  List<DiaryEntry> _entries = [];
  DateTime _selectedDate = DateTime.now();
  bool _loadingSummary = false;
  bool _loadingDiary = false;
  bool _hasLoaded = false;
  String? _error;
  MealGuidance? _mealGuidance;
  bool _loadingMealGuidance = false;
  bool _hasViewedMealGuidance = false;
  int _loadGeneration = 0;

  static const _mealIcons = {
    'breakfast': '🌅',
    'lunch': '☀️',
    'dinner': '🌙',
    'snack': '🍪',
  };

  HomeProvider(this._service, this._mealGuidanceService);

  TodaySummary get summary => _summary;
  List<DiaryEntry> get entries => _entries;
  DateTime get selectedDate => _selectedDate;
  bool get loadingSummary => _loadingSummary;
  bool get loadingDiary => _loadingDiary;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  MealGuidance? get mealGuidance => _mealGuidance;
  bool get loadingMealGuidance => _loadingMealGuidance;
  bool get mascotOpensMealGuidance =>
      _mealGuidance?.isAvailable == true &&
      _mealGuidance!.recommendations.isNotEmpty &&
      (!_hasViewedMealGuidance || _mascotClickIndex == 3);
  bool get shouldAutoRotateMascot =>
      _hasViewedMealGuidance &&
      _mealGuidance?.isAvailable == true &&
      _mealGuidance!.recommendations.isNotEmpty;
  int get remainingCalories => _summary.remainingCalories;

  String getGreeting(AppLocalizations s) {
    final h = DateTime.now().hour;
    if (h < 12) return s.greetingMorning;
    if (h < 18) return s.greetingAfternoon;
    return s.greetingEvening;
  }

  String getAiCoachMessage(AppLocalizations s) {
    if (_summary.aiMessage != null) return _summary.aiMessage!;
    final rem = _summary.remainingCalories;
    if (rem < 200) return s.aiCoachAlmostGoal;
    if (rem > 1000) return s.aiCoachPlentyCalories;
    return s.aiCoachMomentum;
  }

  int _mascotClickIndex = 0;

  void cycleMascotMessage() {
    _mascotClickIndex = (_mascotClickIndex + 1) % 4;
    notifyListeners();
  }

  void markMealGuidanceViewed() {
    _hasViewedMealGuidance = true;
    _mascotClickIndex = 0;
    notifyListeners();
  }

  String getMascotGenZMessage(AppLocalizations s) {
    final guidance = _mealGuidance;
    if (guidance?.goalReached == true) {
      if (_mascotClickIndex > 0) {
        final tips = [
          s.mascotGoalTipWater,
          s.mascotGoalTipSlow,
          s.mascotGoalTipGreat
        ];
        return tips[(_mascotClickIndex - 1) % tips.length];
      }
      return s.mascotGoalReached;
    }
    if (guidance != null &&
        guidance.isAvailable &&
        guidance.recommendations.isNotEmpty) {
      if (!_hasViewedMealGuidance) {
        return s.mascotGuidanceIntro;
      }
      if (_mascotClickIndex == 3) {
        return s.mascotGuidanceOpen;
      }
      if (_mascotClickIndex > 0) {
        final tips = [s.mascotGuidanceTipWater, s.mascotGuidanceTipSlow];
        return tips[(_mascotClickIndex - 1) % tips.length];
      }
      final target =
          _summary.targetCalories > 0 ? _summary.targetCalories : 2000;
      final difference = target - _summary.consumedCalories;
      if (difference < 0) {
        return s.mascotGuidanceOverTarget(difference.abs());
      }
      return s.mascotGuidanceRemaining(difference);
    }

    if (_mascotClickIndex > 0) {
      final tips = [
        s.mascotTipHydration,
        s.mascotTipChew,
        s.mascotTipConsistency
      ];
      return tips[(_mascotClickIndex - 1) % tips.length];
    }

    if (_entries.isEmpty) {
      return s.mascotNoMeals;
    }

    final consumed = _summary.consumedCalories;
    final target = _summary.targetCalories > 0 ? _summary.targetCalories : 2000;
    final diff = target - consumed;

    if (consumed > target + 50) {
      final over = (consumed - target).round();
      return s.mascotOverTarget(over);
    }

    if (diff > 200) {
      final rem = diff.round();
      return s.mascotMissingCalories(rem);
    }

    return s.mascotOnTrack;
  }

  String mascotAssetForTheme(bool isDark) {
    switch (_mealGuidance?.mascotState) {
      case 'thinking':
      case 'hungry_for_data':
        return isDark
            ? 'assets/images/apple_mascot/apple_thinking_dark.png'
            : 'assets/images/apple_mascot/apple_thinking.png';
      case 'recovery':
      case 'gentle_warning':
        return isDark
            ? 'assets/images/apple_mascot/apple_sad_dark.png'
            : 'assets/images/apple_mascot/apple_sad.png';
      case 'encouraging':
      case 'celebrating':
        return isDark
            ? 'assets/images/apple_mascot/apple_happy_dark.png'
            : 'assets/images/apple_mascot/apple_happy.png';
      default:
        // This source already has a transparent background and is safe on
        // both themes.
        return 'assets/images/apple_mascot/apple_hello.png';
    }
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
      _error = 'dataLoadFailed';
    }
    if (loadGeneration != _loadGeneration) return;
    _loadingSummary = false;
    _loadingDiary = false;
    _hasLoaded = true;
    notifyListeners();

    if (_error == null && _isToday(_selectedDate)) {
      unawaited(_loadMealGuidance(loadGeneration));
    } else if (!_isToday(_selectedDate)) {
      _mealGuidance = null;
      _loadingMealGuidance = false;
      notifyListeners();
    }
  }

  Future<void> _loadMealGuidance(int loadGeneration) async {
    _loadingMealGuidance = true;
    notifyListeners();
    MealGuidance? result;
    try {
      result = await _mealGuidanceService.getToday();
    } catch (_) {
      // Guidance is an enhancement; Home remains usable if Gemini/API is
      // temporarily unavailable.
    }
    if (loadGeneration != _loadGeneration) return;
    _mealGuidance = result;
    _loadingMealGuidance = false;
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
      // The mascot message reads this local summary, so calorie guidance is
      // correct immediately after a swipe-delete instead of waiting for an
      // API round trip.
      if (_entries.isEmpty) {
        _mealGuidance = null;
      }
    }
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadToday();
  }

  /// A newly scanned meal always belongs to today. Move Home back from a
  /// historical date before showing its optimistic loading card.
  Future<void> showTodayForNewScan() async {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    await loadToday(forceRefresh: true);
  }

  Future<void> refreshMealGuidance() async {
    if (!_isToday(_selectedDate) || _loadingMealGuidance) return;
    _loadingMealGuidance = true;
    notifyListeners();
    try {
      _mealGuidance = await _mealGuidanceService.getToday(
        generate: true,
        refresh: true,
      );
    } catch (_) {
      // Keep the last useful recommendation on refresh failure.
    }
    _loadingMealGuidance = false;
    notifyListeners();
  }

  /// Generate the natural-language ranking only after the user chooses to
  /// view meal guidance. Home itself only loads DB-filtered candidates.
  Future<void> generateMealGuidance() async {
    if (!_isToday(_selectedDate) || _loadingMealGuidance) return;
    _loadingMealGuidance = true;
    notifyListeners();
    try {
      _mealGuidance = await _mealGuidanceService.getToday(generate: true);
    } catch (_) {
      // Keep the deterministic database candidates if Vertex is unavailable.
    }
    _loadingMealGuidance = false;
    notifyListeners();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String mealIcon(String type) => _mealIcons[type] ?? '🍽️';
}
