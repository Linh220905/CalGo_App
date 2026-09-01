import '../config/api_config.dart';
import '../utils/date_time_utils.dart';

class Ingredient {
  final String ten;
  final double khoiLuongGram;
  final double calo;
  final double carb;
  final double protein;
  final double fat;

  Ingredient({
    required this.ten,
    this.khoiLuongGram = 0,
    this.calo = 0,
    this.carb = 0,
    this.protein = 0,
    this.fat = 0,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      // display_name is localized by the backend after LLM voting. Keep the
      // older keys as fallbacks for historical scans and older API versions.
      ten: (json['display_name'] ?? json['ten'] ?? json['name'] ?? '')
          .toString(),
      khoiLuongGram: (json['khoi_luong_gram'] as num?)?.toDouble() ??
          (json['khoiLuongGram'] as num?)?.toDouble() ??
          (json['weight_g'] as num?)?.toDouble() ??
          (json['gr'] as num?)?.toDouble() ??
          0,
      calo: (json['calo'] as num?)?.toDouble() ?? 0,
      carb: (json['carb'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ScanResult {
  final String id;
  final String timestamp;
  final String? imageUrl;
  final double totalCalo;
  final double totalCarb;
  final double totalProtein;
  final double totalFat;
  final String? monChinh;
  final List<Ingredient> ingredients;
  final String scanType;
  final int dishCount;
  final List<String> dishes;
  final int expEarned;

  ScanResult({
    required this.id,
    required this.timestamp,
    this.imageUrl,
    this.totalCalo = 0,
    this.totalCarb = 0,
    this.totalProtein = 0,
    this.totalFat = 0,
    this.monChinh,
    this.ingredients = const [],
    this.scanType = 'single_dish',
    this.dishCount = 1,
    this.dishes = const [],
    this.expEarned = 0,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id']?.toString() ?? '',
      timestamp: apiDateTimeToLocalIso(json['created_at'] ?? json['timestamp']),
      imageUrl:
          ApiConfig.resolveMediaUrl(json['image_url'] ?? json['imageUrl']),
      totalCalo: (json['total_calo'] as num?)?.toDouble() ??
          (json['totalCalo'] as num?)?.toDouble() ??
          0,
      totalCarb: (json['total_carb'] as num?)?.toDouble() ??
          (json['totalCarb'] as num?)?.toDouble() ??
          0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ??
          (json['totalProtein'] as num?)?.toDouble() ??
          0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ??
          (json['totalFat'] as num?)?.toDouble() ??
          0,
      monChinh: (json['mon_chinh_display'] ??
              json['mon_chinh'] ??
              json['monChinh'])
          ?.toString(),
      scanType: json['scan_type']?.toString() ?? 'single_dish',
      dishCount: (json['dish_count'] as num?)?.toInt() ?? 1,
      dishes: ((json['display_dishes'] as List<dynamic>?) ??
              (json['dishes'] as List<dynamic>?))
          ?.map((item) => item.toString())
          .toList() ??
          const [],
      expEarned: (json['exp_earned'] as num?)?.toInt() ?? 0,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
