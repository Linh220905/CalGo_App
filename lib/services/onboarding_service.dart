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
}
