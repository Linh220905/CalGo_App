import 'dart:math' as math;

enum WeightForecastStatus {
  noData,
  reached,
  healthy,
  slow,
  aggressiveDeficit,
  aggressiveSurplus,
  maintenance,
  opposite,
}

/// Pure calculation for the weight-target timeline.
///
/// Calories above maintenance always move the projection up; calories below
/// maintenance always move it down. The goal only decides whether that
/// movement is helpful or takes the user farther from the target.
class WeightForecast {
  final WeightForecastStatus status;
  final String goal;
  final double currentWeight;
  final double targetWeight;
  final double calories;
  final double maintenanceCalories;
  final double weeklyWeightChangeKg;
  final int? estimatedWeeks;

  const WeightForecast({
    required this.status,
    required this.goal,
    required this.currentWeight,
    required this.targetWeight,
    required this.calories,
    required this.maintenanceCalories,
    required this.weeklyWeightChangeKg,
    required this.estimatedWeeks,
  });

  bool get isReached => status == WeightForecastStatus.reached;
  bool get isWarning =>
      status == WeightForecastStatus.aggressiveDeficit ||
      status == WeightForecastStatus.aggressiveSurplus;
  bool get isMovingAway => status == WeightForecastStatus.opposite;
  bool get isMovingDown => weeklyWeightChangeKg < -0.01;
  bool get isMovingUp => weeklyWeightChangeKg > 0.01;
  double get dailyBalance => maintenanceCalories - calories;
}

class WeightForecastCalculator {
  static const double kcalPerKg = 7700.0;
  static const double meaningfulBalance = 50.0;
  static const double slowBalance = 250.0;
  static const double maxRecommendedBalance = 1000.0;

  static WeightForecast calculate({
    required double currentWeight,
    required double targetWeight,
    required double calories,
    required double calorieTarget,
    required String? goal,
    required double? tdee,
    required double? weeklyGoalKg,
    required double safeFloorCalories,
  }) {
    final normalizedGoal = targetWeight > currentWeight + 0.1
        ? 'gain'
        : targetWeight < currentWeight - 0.1
        ? 'lose'
        : (goal ?? 'maintain').toLowerCase();
    final target = calorieTarget > 0 ? calorieTarget : 2000.0;
    final plannedAdjustment = weeklyGoalKg != null && weeklyGoalKg > 0
        ? weeklyGoalKg * kcalPerKg / 7.0
        : normalizedGoal == 'maintain'
        ? 0.0
        : normalizedGoal == 'lose'
        ? 500.0
        : 400.0;
    final maintenance = tdee != null && tdee > 0
        ? tdee
        : normalizedGoal == 'lose'
        ? target + plannedAdjustment
        : normalizedGoal == 'gain'
        ? target - plannedAdjustment
        : target;
    if (calories <= 0) {
      return WeightForecast(
        status: WeightForecastStatus.noData,
        goal: normalizedGoal,
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        calories: calories,
        maintenanceCalories: maintenance,
        weeklyWeightChangeKg: 0,
        estimatedWeeks: null,
      );
    }
    final weeklyChange = (calories - maintenance) * 7.0 / kcalPerKg;
    final dailyBalance = (maintenance - calories).abs();
    final gap = (currentWeight - targetWeight).abs();
    final reached = gap <= 0.1;
    final tooLow =
        calories < math.max(safeFloorCalories, target * 0.75) ||
        (normalizedGoal == 'lose' &&
            maintenance - calories > maxRecommendedBalance);
    final tooHigh =
        normalizedGoal == 'gain' &&
        calories - maintenance > maxRecommendedBalance;

    WeightForecastStatus status;
    if (reached) {
      status = WeightForecastStatus.reached;
    } else if (tooLow) {
      status = WeightForecastStatus.aggressiveDeficit;
    } else if (tooHigh) {
      status = WeightForecastStatus.aggressiveSurplus;
    } else if (dailyBalance < meaningfulBalance) {
      status = WeightForecastStatus.maintenance;
    } else if (normalizedGoal == 'lose') {
      status = weeklyChange < -0.01
          ? dailyBalance <= slowBalance
                ? WeightForecastStatus.slow
                : WeightForecastStatus.healthy
          : WeightForecastStatus.opposite;
    } else if (normalizedGoal == 'gain') {
      status = weeklyChange > 0.01
          ? dailyBalance <= slowBalance
                ? WeightForecastStatus.slow
                : WeightForecastStatus.healthy
          : WeightForecastStatus.opposite;
    } else {
      status = WeightForecastStatus.opposite;
    }

    final movingTowardTarget = normalizedGoal == 'lose'
        ? weeklyChange < -0.01
        : normalizedGoal == 'gain'
        ? weeklyChange > 0.01
        : weeklyChange.abs() < 0.01;
    // Match the recap service: round the projected number of days to a
    // calendar week, rather than ceiling an already-rounded weekly rate.
    // This keeps the AI recap copy and the timeline badge consistent.
    final projectedDays = dailyBalance > 0
        ? (gap * kcalPerKg / dailyBalance).ceil()
        : 0;
    final weeks = !reached && !tooLow && !tooHigh && movingTowardTarget
        ? math.max(1, (projectedDays / 7.0).round())
        : null;

    return WeightForecast(
      status: status,
      goal: normalizedGoal,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      calories: calories,
      maintenanceCalories: maintenance,
      weeklyWeightChangeKg: weeklyChange,
      estimatedWeeks: weeks,
    );
  }
}
