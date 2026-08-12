import 'api_service.dart';
import '../models/onboarding_data.dart';

class OnboardingService {
  final ApiService _api;

  OnboardingService(this._api);

  Future<Map<String, dynamic>> saveProfile(OnboardingData data) async {
    data.applyDisplayedDefaults();
    final payload = {
      'gender': data.gender!.name,
      'age': data.age!,
      'height_cm': data.heightCm!,
      'current_weight_kg': data.weightKg!,
      'activity_level': data.activityApiValue,
      'goal': data.goalType!.name,
      'target_weight_kg': data.targetWeightKg!,
      'weekly_goal_kg':
          data.goalType == GoalType.maintain ? 0.0 : data.lossPerWeekKg!,
      if (data.dietType != null) 'diet_type': data.dietType!.name,
      if (data.habitPattern != null) 'habit_pattern': data.habitPattern,
      if (data.prepTimePreference != null)
        'prep_time_preference': data.prepTimePreference,
      if (data.budgetPreference != null)
        'budget_preference': data.budgetPreference,
      if (data.nutritionPriority != null)
        'nutrition_priority': data.nutritionPriority,
      if (data.avoidFoods.isNotEmpty) 'avoid_foods': data.avoidFoods,
      if (data.biggestChallenge != null)
        'biggest_challenge': data.biggestChallenge,
      if (data.trainingFrequency != null)
        'training_frequency': data.trainingFrequency,
      if (data.maintenanceFocus != null)
        'maintenance_focus': data.maintenanceFocus,
      if (data.referralSource != null) 'referral_source': data.referralSource,
    };

    final res = await _api.post('/users/onboarding', body: payload);
    if (res is! Map<String, dynamic>) {
      throw StateError('Invalid onboarding response');
    }
    final calories = (res['daily_calorie_target'] as num?)?.toDouble();
    if (calories == null || calories <= 0) {
      throw StateError('Onboarding response is missing calorie targets');
    }
    return res;
  }

  Future<void> completeOnboarding() async {
    try {
      await _api.patch('/users/me', body: {'has_completed_onboarding': true});
    } catch (_) {}
  }

  Future<Map<String, dynamic>> savePremiumPreferences(
    Map<String, dynamic> preferences,
  ) async {
    final response = await _api.patch(
      '/users/preferences/premium',
      body: preferences,
    );
    if (response is! Map<String, dynamic>) {
      throw StateError('Invalid premium preferences response');
    }
    return response;
  }
}
