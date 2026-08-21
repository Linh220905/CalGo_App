import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_build_config.dart';
import '../models/onboarding_data.dart';
import '../services/onboarding_service.dart';
import '../services/analytics_service.dart';
import 'auth_provider.dart';
import 'home_provider.dart';

class OnboardingProvider extends ChangeNotifier {
  final OnboardingService? _onboardingService;
  final AnalyticsService? _analyticsService;

  int _currentStep = 0;
  bool _loading = false;
  bool _initialized = false;
  bool _completed = false;
  bool _testingOnboarding = false;
  String? _error;
  final OnboardingData data = OnboardingData();
  static const _stepKey = 'onboarding_step';
  static const _dataKey = 'onboarding_data';
  static const _versionKey = 'onboarding_version';
  static const _premiumCustomizationKey = 'premium_meal_customization';
  static const int _onboardingVersion = 9;

  OnboardingProvider({
    OnboardingService? onboardingService,
    AnalyticsService? analyticsService,
  })  : _onboardingService = onboardingService,
        _analyticsService = analyticsService;

  int get currentStep => _currentStep;
  bool get loading => _loading;
  bool get initialized => _initialized;
  bool get isCompleted => _completed;
  bool get isTestingOnboarding => _testingOnboarding;
  String? get error => _error;
  bool get isLastStep => _currentStep >= totalSteps - 1;
  double get progress => totalSteps > 0 ? (_currentStep + 1) / totalSteps : 0;

  // The demo screen was removed. Testing releases still skip the Premium
  // paywall, so Account and Home shift one slot earlier in both variants.
  static const int totalSteps = AppBuildConfig.isTesting ? 22 : 23;

  Future<void> init() async {
    if (_initialized) return;

    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _completed = prefs.getBool('onboarding_done') ?? false;

    // Version migration: reset if old onboarding data exists
    final savedVersion = prefs.getInt(_versionKey);
    if (savedVersion == null) {
      await prefs.setInt(_versionKey, _onboardingVersion);
    } else if (savedVersion < _onboardingVersion) {
      final wasCompleted = _completed;
      await prefs.remove(_stepKey);
      await prefs.remove(_dataKey);
      _currentStep = 0;
      _completed = wasCompleted;
      data.clear();
      if (!wasCompleted) {
        await prefs.remove('onboarding_done');
      }
      await prefs.setInt(_versionKey, _onboardingVersion);
      _loading = false;
      _initialized = true;
      notifyListeners();
      return;
    }

    _currentStep = (prefs.getInt(_stepKey) ?? 0).clamp(0, totalSteps - 1);
    // Restore persisted onboarding data
    final jsonStr = prefs.getString(_dataKey);
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          _restoreData(decoded);
        } else {
          await prefs.remove(_dataKey);
        }
      } catch (_) {
        // A stale/corrupt local draft should never trap onboarding on a
        // permanent loading screen.
        await prefs.remove(_dataKey);
        data.clear();
      }
    }
    _loading = false;
    _initialized = true;
    notifyListeners();
  }

  /// Clears saved onboarding progress and jumps to the welcome screen.
  /// Skips splash so reset feels instant and avoids the old SVG mascot flash.
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stepKey);
    await prefs.remove(_dataKey);
    await prefs.remove('onboarding_done');
    _completed = false;
    _testingOnboarding = true;
    _currentStep = 1;
    data.clear();
    await prefs.setInt(_stepKey, 1);
    notifyListeners();
  }

  /// Clears the in-memory completion step when the authenticated account does
  /// not have onboarding completed. This prevents a previous account's local
  /// completion step from rendering a blank onboarding screen for a new account.
  void resetLocalProgressForIncompleteAccount() {
    if (_currentStep < totalSteps && !_completed) return;
    _currentStep = 0;
    _completed = false;
    data.clear();
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.remove(_stepKey);
      await prefs.remove(_dataKey);
      await prefs.remove('onboarding_done');
    });
    notifyListeners();
  }

  void _restoreData(Map<String, dynamic> json) {
    if (json['name'] is String) {
      data.name = json['name'] as String;
    }
    data.gender = _enumByName(Gender.values, json['gender']) ?? data.gender;
    if (json['age'] is num) {
      data.age = (json['age'] as num).toInt();
    }
    if (json['heightCm'] is num) {
      data.heightCm = (json['heightCm'] as num).toDouble();
    }
    if (json['weightKg'] is num) {
      data.weightKg = (json['weightKg'] as num).toDouble();
    }
    data.goalType =
        _enumByName(GoalType.values, json['goalType']) ?? data.goalType;
    if (json['targetWeightKg'] is num) {
      data.targetWeightKg = (json['targetWeightKg'] as num).toDouble();
    }
    if (json['targetWeeks'] is num) {
      data.targetWeeks = (json['targetWeeks'] as num).toInt();
    }
    if (json['lossPerWeekKg'] is num) {
      data.lossPerWeekKg = (json['lossPerWeekKg'] as num).toDouble();
    }
    data.activityLevel =
        _enumByName(ActivityLevel.values, json['activityLevel']) ??
            data.activityLevel;
    if (json['sports'] is List) {
      data.sports = (json['sports'] as List).cast<String>();
    }
    data.dietType =
        _enumByName(DietType.values, json['dietType']) ?? data.dietType;
    if (json['allergies'] is String) {
      data.allergies = json['allergies'] as String;
    }
    if (json['referralSource'] is String) {
      data.referralSource = json['referralSource'] as String;
    }
    // New fields
    if (json['pains'] is List) {
      data.pains = (json['pains'] as List).cast<String>();
    }
    if (json['motivation'] is String) {
      data.motivation = json['motivation'] as String;
    }
    if (json['habitPattern'] is String) {
      data.habitPattern = json['habitPattern'] as String;
    }
    if (json['prepTimePreference'] is String) {
      data.prepTimePreference = json['prepTimePreference'] as String;
    }
    if (json['budgetPreference'] is String) {
      data.budgetPreference = json['budgetPreference'] as String;
    }
    if (json['nutritionPriority'] is String) {
      data.nutritionPriority = json['nutritionPriority'] as String;
    }
    if (json['avoidFoods'] is List) {
      data.avoidFoods = (json['avoidFoods'] as List).cast<String>();
    }
    if (json['biggestChallenge'] is String) {
      data.biggestChallenge = json['biggestChallenge'] as String;
    }
    if (json['trainingFrequency'] is String) {
      data.trainingFrequency = json['trainingFrequency'] as String;
    }
    if (json['maintenanceFocus'] is String) {
      data.maintenanceFocus = json['maintenanceFocus'] as String;
    }
    if (json['likedApp'] is bool) {
      data.likedApp = json['likedApp'] as bool;
    }
    if (json['accountMethod'] is String) {
      data.accountMethod = json['accountMethod'] as String;
    }
  }

  T? _enumByName<T extends Enum>(List<T> values, dynamic rawValue) {
    if (rawValue is! String) return null;
    for (final value in values) {
      if (value.name == rawValue) return value;
    }
    return null;
  }

  Future<void> _persistData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, jsonEncode(data.toJson()));
  }

  Future<void> nextStep() async {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_stepKey, _currentStep);
      notifyListeners();
    }
  }

  Future<void> setStep(int step) async {
    _currentStep = step.clamp(0, totalSteps - 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepKey, _currentStep);
    notifyListeners();
  }

  Future<void> prepareAnalysis() async {
    data.applyDisplayedDefaults();
    await _persistData();
    notifyListeners();
  }

  Future<bool> completeOnboarding({
    AuthProvider? authProvider,
    HomeProvider? homeProvider,
  }) async {
    if (_loading) return false;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      data.applyDisplayedDefaults();
      // Wait for the calculated nutrition targets to be persisted before Home
      // requests them. On failure, keep the onboarding draft so the user can
      // retry instead of silently landing on the 2,000 kcal fallback.
      if (_onboardingService != null) {
        final res = await _onboardingService.saveProfile(data);
        if (res['user'] is Map<String, dynamic> && authProvider != null) {
          authProvider.updateUserFromJson(res['user'] as Map<String, dynamic>);
        }
      }

      if (authProvider != null) {
        await authProvider.refreshUser();
      }

      if (homeProvider != null) {
        homeProvider.invalidateCache();
      }

      _currentStep = totalSteps;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      _completed = true;
      _testingOnboarding = false;
      await prefs.setInt(_versionKey, _onboardingVersion);
      await prefs.remove(_stepKey);
      await prefs.remove(_dataKey);
      _loading = false;
      notifyListeners();
      // The backend deduplicates this event per user. Keep tracking outside
      // the save/route-critical path so analytics cannot block onboarding.
      unawaited(_analyticsService?.trackOnboardingCompleted());
      return true;
    } catch (e) {
      debugPrint('Unable to complete onboarding: $e');
      _error = 'onboardingSaveNetworkFailed';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setName(String v) async {
    data.name = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setGender(Gender v) async {
    data.gender = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setAge(int v) async {
    data.age = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setHeight(double v) async {
    data.heightCm = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setWeight(double v) async {
    data.weightKg = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setGoalType(GoalType v) async {
    data.goalType = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setTargetWeight(double v) async {
    data.targetWeightKg = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setTargetWeeks(int v) async {
    data.targetWeeks = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setLossPerWeek(double v) async {
    data.lossPerWeekKg = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setActivityLevel(ActivityLevel v) async {
    data.activityLevel = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setSports(List<String> v) async {
    data.sports = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setDietType(DietType v) async {
    data.dietType = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setAllergies(String v) async {
    data.allergies = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setReferralSource(String v) async {
    data.referralSource = v;
    await _persistData();
    notifyListeners();
  }

  // New setters
  Future<void> setPains(List<String> v) async {
    data.pains = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setMotivation(String v) async {
    data.motivation = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setHabitPattern(String v) async {
    data.habitPattern = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setPrepTimePreference(String v) async {
    data.prepTimePreference = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setBudgetPreference(String v) async {
    data.budgetPreference = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setNutritionPriority(String v) async {
    data.nutritionPriority = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setAvoidFoods(List<String> v) async {
    data.avoidFoods = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setBiggestChallenge(String v) async {
    data.biggestChallenge = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setTrainingFrequency(String v) async {
    data.trainingFrequency = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setMaintenanceFocus(String v) async {
    data.maintenanceFocus = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setLikedApp(bool v) async {
    data.likedApp = v;
    await _persistData();
    notifyListeners();
  }

  Future<void> setAccountMethod(String v) async {
    data.accountMethod = v;
    await _persistData();
    notifyListeners();
  }

  String _premiumCustomizationStorageKey(String? accountId) {
    final normalized = accountId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return _premiumCustomizationKey;
    }
    return '${_premiumCustomizationKey}_$normalized';
  }

  /// Returns whether the post-purchase personalization quiz has already been
  /// completed for this account on this device.
  ///
  /// Older builds stored one unscoped key.  Migrate that key to the current
  /// account on first read so an existing user is not asked the quiz again,
  /// while future account switches remain isolated.
  Future<bool> hasPremiumCustomization({String? accountId}) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = _premiumCustomizationStorageKey(accountId);

    bool isValid(String? raw) {
      if (raw == null || raw.isEmpty) return false;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) return false;
        return decoded['meal_pattern'] is String &&
            decoded['variety_preference'] is String &&
            decoded['assistant_priority'] is String;
      } catch (_) {
        return false;
      }
    }

    if (isValid(prefs.getString(scopedKey))) return true;
    if (scopedKey == _premiumCustomizationKey) {
      return isValid(prefs.getString(_premiumCustomizationKey));
    }

    // One-time migration from the pre-account-scoped key.
    final legacy = prefs.getString(_premiumCustomizationKey);
    if (!isValid(legacy)) return false;
    await prefs.setString(scopedKey, legacy!);
    await prefs.remove(_premiumCustomizationKey);
    return true;
  }

  Future<void> saveMealCustomization(
    Map<String, dynamic> customization, {
    String? accountId,
  }) async {
    // Keep the answers locally before the network write.  A temporary backend
    // outage must not erase the user's choices or trap the post-purchase flow.
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = _premiumCustomizationStorageKey(accountId);
    await prefs.setString(scopedKey, jsonEncode(customization));
    if (scopedKey != _premiumCustomizationKey) {
      await prefs.remove(_premiumCustomizationKey);
    }
    if (_onboardingService != null && !AppBuildConfig.isTesting) {
      await _onboardingService.savePremiumPreferences(customization);
    }
    notifyListeners();
  }
}
