import '../models/exercise_entry.dart';
import 'api_service.dart';

class ExerciseService {
  final ApiService _api;

  ExerciseService(this._api);

  Future<ExerciseDaySummary> getDaily(String dateKey) async {
    final response = await _api.get('/exercise/daily/$dateKey');
    if (response is! Map) {
      throw StateError('Invalid exercise daily response');
    }
    return ExerciseDaySummary.fromJson(Map<String, dynamic>.from(response));
  }

  Future<ExerciseEntry> createExercise({
    required String dateKey,
    required String activityType,
    String? intensity,
    int? durationMinutes,
    double? caloriesBurned,
    DateTime? occurredAt,
  }) async {
    final response = await _api.post(
      '/exercise',
      body: {
        'date_key': dateKey,
        'activity_type': activityType,
        if (intensity != null) 'intensity': intensity,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (caloriesBurned != null) 'calories_burned': caloriesBurned,
        'occurred_at': (occurredAt ?? DateTime.now()).toUtc().toIso8601String(),
      },
    );
    if (response is! Map) {
      throw StateError('Invalid exercise response');
    }
    return ExerciseEntry.fromJson(Map<String, dynamic>.from(response));
  }

  Future<ExerciseDaySummary> syncHealthCalories({
    required String dateKey,
    required double caloriesBurned,
  }) async {
    final response = await _api.post(
      '/exercise/health-sync',
      body: {
        'date_key': dateKey,
        'calories_burned': caloriesBurned.clamp(0, 10000),
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    if (response is! Map) {
      throw StateError('Invalid Health sync response');
    }
    return ExerciseDaySummary.fromJson(Map<String, dynamic>.from(response));
  }

  Future<ExerciseDaySummary> deleteExercise(String entryId) async {
    final response = await _api.delete('/exercise/$entryId');
    if (response is! Map) {
      throw StateError('Invalid exercise deletion response');
    }
    return ExerciseDaySummary.fromJson(Map<String, dynamic>.from(response));
  }
}
