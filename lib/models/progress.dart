class WeightPoint {
  final String id;
  final double weightKg;
  final DateTime date;

  const WeightPoint({
    required this.id,
    required this.weightKg,
    required this.date,
  });

  factory WeightPoint.fromJson(Map<String, dynamic> json) => WeightPoint(
    id: json['id']?.toString() ?? '',
    weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
    date:
        DateTime.tryParse(json['logged_date']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class ProgressPhoto {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final DateTime capturedDate;
  final DateTime createdAt;

  const ProgressPhoto({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.capturedDate,
    required this.createdAt,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
    id: json['id']?.toString() ?? '',
    imageUrl: json['image_url']?.toString() ?? '',
    thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
    capturedDate:
        DateTime.tryParse(json['captured_date']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    createdAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class WeightChangeItem {
  final int periodDays;
  final double diffKg;
  final String label;
  final List<double> sparkline;

  const WeightChangeItem({
    required this.periodDays,
    required this.diffKg,
    required this.label,
    required this.sparkline,
  });

  factory WeightChangeItem.fromJson(Map<String, dynamic> json) => WeightChangeItem(
    periodDays: (json['period_days'] as num?)?.toInt() ?? 7,
    diffKg: (json['diff_kg'] as num?)?.toDouble() ?? 0.0,
    label: json['label']?.toString() ?? '',
    sparkline: (json['sparkline'] as List? ?? [])
        .map((e) => (e as num).toDouble())
        .toList(),
  );
}

class ProgressStats {
  final int rangeDays;
  final double? currentWeightKg;
  final double? startWeightKg;
  final double? targetWeightKg;
  final double? progressPercent;
  final double? heightCm;
  final double? bmi;
  final String? bmiCategory;
  final List<WeightPoint> weightHistory;
  final List<WeightChangeItem> weightChanges;
  final List<ProgressPhoto> progressPhotos;

  const ProgressStats({
    required this.rangeDays,
    this.currentWeightKg,
    this.startWeightKg,
    this.targetWeightKg,
    this.progressPercent,
    this.heightCm,
    this.bmi,
    this.bmiCategory,
    this.weightHistory = const [],
    this.weightChanges = const [],
    this.progressPhotos = const [],
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    final weights = json['weight_history'];
    final changes = json['weight_changes'];
    final photos = json['progress_photos'];
    return ProgressStats(
      rangeDays: (json['range_days'] as num?)?.toInt() ?? 90,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
      startWeightKg: (json['start_weight_kg'] as num?)?.toDouble(),
      targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble(),
      progressPercent: (json['progress_percent'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiCategory: json['bmi_category']?.toString(),
      weightHistory: (weights is List ? weights : const <dynamic>[])
          .whereType<Map>()
          .map((item) => WeightPoint.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      weightChanges: (changes is List ? changes : const <dynamic>[])
          .whereType<Map>()
          .map((item) => WeightChangeItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      progressPhotos: (photos is List ? photos : const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => ProgressPhoto.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}
