import 'package:calgo/utils/exercise_calorie_calculator.dart';
import 'package:calgo/models/home_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('running uses Compendium MET and net active calories', () {
    final calories = ExerciseCalorieCalculator.estimateActiveCalories(
      activityType: 'running',
      intensity: ExerciseIntensity.moderate,
      weightKg: 70,
      durationMinutes: 30,
    );

    expect(
      ExerciseCalorieCalculator.metFor('running', ExerciseIntensity.moderate),
      9.3,
    );
    expect(calories, closeTo(290.5, 0.01));
  });

  test('workout excludes resting energy already in the daily target', () {
    final calories = ExerciseCalorieCalculator.estimateActiveCalories(
      activityType: 'workout',
      intensity: ExerciseIntensity.low,
      weightKg: 60,
      durationMinutes: 60,
    );

    expect(calories, closeTo(150, 0.01));
  });

  test('walking, cycling, swimming use METCompendium 2024', () {
    final walkCal = ExerciseCalorieCalculator.estimateActiveCalories(
      activityType: 'walking',
      intensity: ExerciseIntensity.moderate,
      weightKg: 60,
      durationMinutes: 60,
    );
    expect(walkCal, closeTo(168.0, 0.01));

    final cycleCal = ExerciseCalorieCalculator.estimateActiveCalories(
      activityType: 'cycling',
      intensity: ExerciseIntensity.moderate,
      weightKg: 70,
      durationMinutes: 30,
    );
    expect(cycleCal, closeTo(227.5, 0.01));

    final swimCal = ExerciseCalorieCalculator.estimateActiveCalories(
      activityType: 'swimming',
      intensity: ExerciseIntensity.high,
      weightKg: 65,
      durationMinutes: 45,
    );
    expect(swimCal, closeTo(438.75, 0.01));
  });

  test('burned calories increase the effective daily calorie target', () {
    final summary = TodaySummary(
      consumedCalories: 1800,
      burnedCalories: 300,
      targetCalories: 2000,
    );

    expect(summary.effectiveTargetCalories, 2300);
    expect(summary.remainingCalories, 500);
    expect(summary.caloriesProgress, closeTo(1800 / 2300, 0.0001));
  });
}
