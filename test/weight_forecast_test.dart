import 'package:flutter_test/flutter_test.dart';

import 'package:calgo/utils/weight_forecast.dart';

WeightForecast calculate({
  required double current,
  required double target,
  required double calories,
  String goal = 'lose',
}) {
  return WeightForecastCalculator.calculate(
    currentWeight: current,
    targetWeight: target,
    calories: calories,
    calorieTarget: goal == 'lose' ? 2000 : 2600,
    goal: goal,
    tdee: goal == 'lose' ? 2500 : 2200,
    weeklyGoalKg: 0.5,
    safeFloorCalories: 1500,
  );
}

void main() {
  test('lose weight: healthy deficit projects down toward target', () {
    final result = calculate(current: 70, target: 60, calories: 2000);

    expect(result.status, WeightForecastStatus.healthy);
    expect(result.weeklyWeightChangeKg, closeTo(-0.45, 0.01));
    expect(result.estimatedWeeks, isNotNull);
  });

  test('recap ETA rounds calendar days consistently with the AI summary', () {
    final result = calculate(current: 60.9, target: 59, calories: 1544);

    // 15.3 projected days becomes 2 calendar weeks, not 3 weeks from
    // ceiling the fractional week directly.
    expect(result.estimatedWeeks, 2);
  });

  test('lose weight: mild deficit projects down but marks slow progress', () {
    final result = calculate(current: 70, target: 60, calories: 2250);

    expect(result.status, WeightForecastStatus.slow);
    expect(result.weeklyWeightChangeKg, closeTo(-0.23, 0.01));
  });

  test('lose weight: maintenance is the only flat projection', () {
    final result = calculate(current: 70, target: 60, calories: 2500);

    expect(result.status, WeightForecastStatus.maintenance);
    expect(result.weeklyWeightChangeKg, closeTo(0, 0.001));
    expect(result.estimatedWeeks, isNull);
  });

  test('lose weight: surplus projects up and away from target', () {
    final result = calculate(current: 70, target: 60, calories: 2800);

    expect(result.status, WeightForecastStatus.opposite);
    expect(result.weeklyWeightChangeKg, greaterThan(0));
    expect(result.estimatedWeeks, isNull);
  });

  test('lose weight: excessive deficit is a safety warning', () {
    final result = calculate(current: 70, target: 60, calories: 1200);

    expect(result.status, WeightForecastStatus.aggressiveDeficit);
    expect(result.weeklyWeightChangeKg, lessThan(0));
    expect(result.estimatedWeeks, isNull);
  });

  test('gain weight: healthy surplus projects up toward target', () {
    final result = calculate(
      current: 60,
      target: 70,
      calories: 2600,
      goal: 'gain',
    );

    expect(result.status, WeightForecastStatus.healthy);
    expect(result.weeklyWeightChangeKg, closeTo(0.36, 0.01));
    expect(result.estimatedWeeks, isNotNull);
  });

  test('gain weight: deficit projects down and away from target', () {
    final result = calculate(
      current: 60,
      target: 70,
      calories: 2000,
      goal: 'gain',
    );

    expect(result.status, WeightForecastStatus.opposite);
    expect(result.weeklyWeightChangeKg, lessThan(0));
    expect(result.estimatedWeeks, isNull);
  });

  test('gain weight: excessive surplus warns without an optimistic ETA', () {
    final result = calculate(
      current: 60,
      target: 70,
      calories: 3400,
      goal: 'gain',
    );

    expect(result.status, WeightForecastStatus.aggressiveSurplus);
    expect(result.weeklyWeightChangeKg, greaterThan(0));
    expect(result.estimatedWeeks, isNull);
  });

  test('maintain weight: near maintenance stays flat', () {
    final result = calculate(
      current: 65,
      target: 65,
      calories: 2500,
      goal: 'maintain',
    );

    expect(result.status, WeightForecastStatus.reached);
    expect(result.estimatedWeeks, isNull);
  });

  test('no calories produces a neutral no-data state', () {
    final result = calculate(current: 70, target: 60, calories: 0);

    expect(result.status, WeightForecastStatus.noData);
    expect(result.weeklyWeightChangeKg, 0);
    expect(result.estimatedWeeks, isNull);
  });
}
