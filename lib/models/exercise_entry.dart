class ExerciseEntry {
  final String id;
  final String dateKey;
  final String activityType;
  final String? intensity;
  final String source;
  final int? durationMinutes;
  final double caloriesBurned;
  final double? metValue;
  final DateTime occurredAt;

  const ExerciseEntry({
    required this.id,
    required this.dateKey,
    required this.activityType,
    required this.source,
    required this.caloriesBurned,
    required this.occurredAt,
    this.intensity,
    this.durationMinutes,
    this.metValue,
  });

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      id: json['id']?.toString() ?? '',
      dateKey: json['date_key']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? 'manual',
      intensity: json['intensity']?.toString(),
      source: json['source']?.toString() ?? 'manual',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      caloriesBurned: (json['calories_burned'] as num?)?.toDouble() ?? 0,
      metValue: (json['met_value'] as num?)?.toDouble(),
      occurredAt:
          DateTime.tryParse(json['occurred_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ExerciseDaySummary {
  final String dateKey;
  final double appCalories;
  final double healthCalories;
  final double totalCalories;
  final List<ExerciseEntry> entries;

  const ExerciseDaySummary({
    required this.dateKey,
    required this.appCalories,
    required this.healthCalories,
    required this.totalCalories,
    required this.entries,
  });

  factory ExerciseDaySummary.empty(String dateKey) => ExerciseDaySummary(
    dateKey: dateKey,
    appCalories: 0,
    healthCalories: 0,
    totalCalories: 0,
    entries: const [],
  );

  factory ExerciseDaySummary.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    return ExerciseDaySummary(
      dateKey: json['date_key']?.toString() ?? '',
      appCalories: (json['app_calories'] as num?)?.toDouble() ?? 0,
      healthCalories: (json['health_calories'] as num?)?.toDouble() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
      entries: rawEntries is List
          ? rawEntries
                .whereType<Map>()
                .map(
                  (item) =>
                      ExerciseEntry.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }
}
