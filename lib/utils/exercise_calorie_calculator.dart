enum ExerciseIntensity { low, moderate, high }

class ExerciseCalorieCalculator {
  ExerciseCalorieCalculator._();

  // 2024 Adult Compendium of Physical Activities:
  // https://pacompendium.com/adult-compendium/
  static const Map<String, Map<ExerciseIntensity, double>> _mets = {
    'running': {
      ExerciseIntensity.low: 6.5,
      ExerciseIntensity.moderate: 9.3,
      ExerciseIntensity.high: 12.0,
    },
    'workout': {
      ExerciseIntensity.low: 3.5,
      ExerciseIntensity.moderate: 5.0,
      ExerciseIntensity.high: 7.5,
    },
    'walking': {
      ExerciseIntensity.low: 3.0,
      ExerciseIntensity.moderate: 3.8,
      ExerciseIntensity.high: 4.8,
    },
    'cycling': {
      ExerciseIntensity.low: 5.5,
      ExerciseIntensity.moderate: 7.5,
      ExerciseIntensity.high: 10.0,
    },
    'swimming': {
      ExerciseIntensity.low: 6.0,
      ExerciseIntensity.moderate: 8.0,
      ExerciseIntensity.high: 10.0,
    },
  };

  static double metFor(String activityType, ExerciseIntensity intensity) {
    final met = _mets[activityType]?[intensity];
    if (met == null) throw ArgumentError('Unsupported exercise selection');
    return met;
  }

  /// Estimates net active energy, excluding the one-MET resting component.
  static double estimateActiveCalories({
    required String activityType,
    required ExerciseIntensity intensity,
    required double weightKg,
    required int durationMinutes,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0) return 0;
    final met = metFor(activityType, intensity);
    return (met - 1) * weightKg * durationMinutes / 60;
  }
}
