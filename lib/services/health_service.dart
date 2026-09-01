import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  Future<void>? _configuration;

  Future<void> _ensureConfigured() {
    return _configuration ??= _health.configure();
  }

  /// This feature only needs active energy. Keep the authorization prompt
  /// minimal until another Health feature is actually shipped.
  static const List<HealthDataType> readTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static const List<HealthDataType> writeTypes = [];

  /// All types currently requested by CalGo.
  static const List<HealthDataType> types = [
    ...readTypes,
    ...writeTypes,
  ];

  /// Permissions list matching `types`
  static const List<HealthDataAccess> permissions = [HealthDataAccess.READ];

  /// Check if the app currently has authorization for requested types
  Future<bool> hasPermissions() async {
    try {
      await _ensureConfigured();
      final hasPerm = await _health.hasPermissions(
        types,
        permissions: permissions,
      );
      return hasPerm ?? false;
    } catch (e) {
      debugPrint('HealthService: Error checking permissions: $e');
      return false;
    }
  }

  /// Request authorization from native Apple Health / Health Connect dialog
  Future<bool> requestAuthorization() async {
    try {
      await _ensureConfigured();
      // Calling requestAuthorization triggers the native iOS Apple Health modal prompt!
      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      return authorized;
    } catch (e) {
      debugPrint('HealthService: Error requesting authorization: $e');
      return false;
    }
  }

  /// Fetch today's total steps count
  Future<int> getTodaySteps() async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('HealthService: Error getting today steps: $e');
      return 0;
    }
  }

  /// Fetch active calories burned today
  Future<double> getTodayActiveCalories() async {
    return getActiveCaloriesForDay(DateTime.now());
  }

  /// Fetch cumulative active energy for one local calendar day.
  Future<double> getActiveCaloriesForDay(DateTime day) async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(day.year, day.month, day.day);
      final nextMidnight = midnight.add(const Duration(days: 1));
      if (midnight.isAfter(now)) return 0;
      final endTime = nextMidnight.isBefore(now) ? nextMidnight : now;
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: endTime,
      );
      double totalCal = 0.0;
      for (final point in dataPoints) {
        final val = point.value;
        if (val is NumericHealthValue) {
          totalCal += val.numericValue.toDouble();
        }
      }
      return totalCal;
    } catch (e) {
      debugPrint('HealthService: Error getting active calories: $e');
      return 0.0;
    }
  }

  /// Write nutrition log entry to Apple Health
  Future<bool> writeMealNutrition({
    required double calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    DateTime? timestamp,
  }) async {
    final time = timestamp ?? DateTime.now();
    try {
      await _ensureConfigured();
      bool success = true;

      if (calories > 0) {
        final calSuccess = await _health.writeHealthData(
          value: calories,
          type: HealthDataType.DIETARY_ENERGY_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.KILOCALORIE,
        );
        success = success && calSuccess;
      }

      if (proteinGrams != null && proteinGrams > 0) {
        final proteinSuccess = await _health.writeHealthData(
          value: proteinGrams,
          type: HealthDataType.DIETARY_PROTEIN_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.GRAM,
        );
        success = success && proteinSuccess;
      }

      if (carbsGrams != null && carbsGrams > 0) {
        final carbsSuccess = await _health.writeHealthData(
          value: carbsGrams,
          type: HealthDataType.DIETARY_CARBS_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.GRAM,
        );
        success = success && carbsSuccess;
      }

      if (fatGrams != null && fatGrams > 0) {
        final fatSuccess = await _health.writeHealthData(
          value: fatGrams,
          type: HealthDataType.DIETARY_FATS_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.GRAM,
        );
        success = success && fatSuccess;
      }

      return success;
    } catch (e) {
      debugPrint('HealthService: Error writing nutrition data: $e');
      return false;
    }
  }

  /// Write weight measurement to Apple Health
  Future<bool> writeWeight(double weightKg, {DateTime? timestamp}) async {
    final time = timestamp ?? DateTime.now();
    try {
      await _ensureConfigured();
      return await _health.writeHealthData(
        value: weightKg,
        type: HealthDataType.WEIGHT,
        startTime: time,
        endTime: time,
        unit: HealthDataUnit.KILOGRAM,
      );
    } catch (e) {
      debugPrint('HealthService: Error writing weight data: $e');
      return false;
    }
  }
}
