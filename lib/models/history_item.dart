import '../config/api_config.dart';
import '../utils/date_time_utils.dart';

class HistoryItem {
  final String id;
  final String monChinh;
  final double totalCalo;
  final double totalCarb;
  final double totalProtein;
  final double totalFat;
  final String? thumbnailUrl;
  final String? imageUrl;
  final String createdAt;

  HistoryItem({
    required this.id,
    required this.monChinh,
    this.totalCalo = 0,
    this.totalCarb = 0,
    this.totalProtein = 0,
    this.totalFat = 0,
    this.thumbnailUrl,
    this.imageUrl,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      monChinh: (json['mon_chinh'] as String?) ?? '',
      totalCalo: (json['total_calo'] as num?)?.toDouble() ?? 0,
      totalCarb: (json['total_carb'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0,
      thumbnailUrl: ApiConfig.resolveMediaUrl(json['thumbnail_url']),
      imageUrl: ApiConfig.resolveMediaUrl(json['image_url']),
      createdAt: apiDateTimeToLocalIso(json['created_at']),
    );
  }
}
