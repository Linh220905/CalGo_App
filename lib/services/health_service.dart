import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  bool _isConfigured = false;

  void _ensureConfigured() {
    if (!_isConfigured) {
      _health.configure();
      _isConfigured = true;
    }
  }

  /// Data types requested for reading from Apple Health / Health Connect
  static const List<HealthDataType> readTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
  ];

  /// Data types requested for writing to Apple Health
  static const List<HealthDataType> writeTypes = [
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
    HealthDataType.WEIGHT,
  ];

  /// All types requested by CalGo
  List<HealthDataType> get types => [...readTypes, ...writeTypes];

  /// Permissions list matching `types`
  List<HealthDataAccess> get permissions => [
        ...readTypes.map((_) => HealthDataAccess.READ),
        ...writeTypes.map((_) => HealthDataAccess.READ_WRITE),
      ];

  /// Check if the app currently has authorization for requested types
  Future<bool> hasPermissions() async {
    _ensureConfigured();
    try {
      final hasPerm = await _health.hasPermissions(types, permissions: permissions);
      return hasPerm ?? false;
    } catch (e) {
      debugPrint('HealthService: Error checking permissions: $e');
      return false;
    }
  }

  /// Request authorization from native Apple Health / Health Connect dialog
  Future<bool> requestAuthorization() async {
    _ensureConfigured();
    try {
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
    _ensureConfigured();
    try {
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
    _ensureConfigured();
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
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
    _ensureConfigured();
    final time = timestamp ?? DateTime.now();
    try {
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
        await _health.writeHealthData(
          value: proteinGrams,
          type: HealthDataType.DIETARY_PROTEIN_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.GRAM,
        );
      }

      if (carbsGrams != null && carbsGrams > 0) {
        await _health.writeHealthData(
          value: carbsGrams,
          type: HealthDataType.DIETARY_CARBS_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.GRAM,
        );
      }

      if (fatGrams != null && fatGrams > 0) {
        await _health.writeHealthData(
          value: fatGrams,
          type: HealthDataType.DIETARY_FATS_CONSUMED,
          startTime: time,
          endTime: time,
          unit: HealthDataUnit.GRAM,
        );
      }

      return success;
    } catch (e) {
      debugPrint('HealthService: Error writing nutrition data: $e');
      return false;
    }
  }

  /// Write weight measurement to Apple Health
  Future<bool> writeWeight(double weightKg, {DateTime? timestamp}) async {
    _ensureConfigured();
    final time = timestamp ?? DateTime.now();
    try {
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
