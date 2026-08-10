import '../models/meal_guidance.dart';
import 'api_service.dart';

class MealGuidanceService {
  final ApiService _api;

  MealGuidanceService(this._api);

  Future<MealGuidance> getToday({
    bool generate = false,
    bool refresh = false,
  }) async {
    final query = <String>[];
    if (generate) query.add('generate=true');
    if (refresh) query.add('refresh=true');
    final response = await _api.get(
      '/nutrition/meal-guidance/today${query.isEmpty ? '' : '?${query.join('&')}'}',
    );
    if (response is! Map<String, dynamic>) {
      throw StateError('Invalid meal guidance response');
    }
    return MealGuidance.fromJson(response);
  }
}
