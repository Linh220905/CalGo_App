import '../config/api_config.dart';
import '../l10n/generated/app_localizations.dart';

enum MealTimeCategory { breakfast, lunch, dinner }

enum DishTagKey { highProtein, quick, energetic, light, balanced, healthy }

class WhatToEatDish {
  final String id;
  final String name;
  final MealTimeCategory mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DishTagKey tagKey;
  final String emoji;

  /// Server-hosted image path (relative `/api/v1/...` or full `https://...`).
  final String imageUrl;

  const WhatToEatDish({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tagKey,
    required this.emoji,
    required this.imageUrl,
  });

  /// Full URL resolved against [ApiConfig.baseUrl] for remote loading & caching.
  String get resolvedImageUrl => ApiConfig.resolveMediaUrl(imageUrl) ?? '';

  String localizedTag(AppLocalizations s) => switch (tagKey) {
    DishTagKey.highProtein => s.dishTagHighProtein,
    DishTagKey.quick => s.dishTagQuick,
    DishTagKey.energetic => s.dishTagEnergetic,
    DishTagKey.light => s.dishTagLight,
    DishTagKey.balanced => s.dishTagBalanced,
    DishTagKey.healthy => s.dishTagHealthy,
  };

  static MealTimeCategory _parseMealType(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'breakfast' => MealTimeCategory.breakfast,
      'lunch' => MealTimeCategory.lunch,
      'dinner' => MealTimeCategory.dinner,
      _ => MealTimeCategory.lunch,
    };
  }

  static String _mealTypeToApi(MealTimeCategory category) => switch (category) {
    MealTimeCategory.breakfast => 'breakfast',
    MealTimeCategory.lunch => 'lunch',
    MealTimeCategory.dinner => 'dinner',
  };

  static DishTagKey _parseTagKey(Object? value) {
    final normalized = value?.toString().trim().toLowerCase().replaceAll(
      '-',
      '_',
    );
    return switch (normalized) {
      'high_protein' || 'highprotein' => DishTagKey.highProtein,
      'quick' => DishTagKey.quick,
      'energetic' => DishTagKey.energetic,
      'light' => DishTagKey.light,
      'healthy' => DishTagKey.healthy,
      _ => DishTagKey.balanced,
    };
  }

  static String _tagKeyToApi(DishTagKey key) => switch (key) {
    DishTagKey.highProtein => 'high_protein',
    DishTagKey.quick => 'quick',
    DishTagKey.energetic => 'energetic',
    DishTagKey.light => 'light',
    DishTagKey.balanced => 'balanced',
    DishTagKey.healthy => 'healthy',
  };

  factory WhatToEatDish.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? raw) {
      if (raw is int) return raw;
      if (raw is num) return raw.round();
      return int.tryParse(raw?.toString() ?? '') ?? 0;
    }

    return WhatToEatDish(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      mealType: _parseMealType(json['meal_type'] ?? json['mealType']),
      calories: parseInt(json['calories']),
      protein: parseInt(json['protein']),
      carbs: parseInt(json['carbs']),
      fat: parseInt(json['fat']),
      tagKey: _parseTagKey(json['tag_key'] ?? json['tagKey']),
      emoji: (json['emoji'] ?? '🍽️').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'meal_type': _mealTypeToApi(mealType),
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'tag_key': _tagKeyToApi(tagKey),
    'emoji': emoji,
    'image_url': imageUrl,
  };

  static MealTimeCategory currentMealCategory() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return MealTimeCategory.breakfast;
    } else if (hour >= 11 && hour < 16) {
      return MealTimeCategory.lunch;
    } else {
      return MealTimeCategory.dinner;
    }
  }

  static const String _imageBase = '/api/v1/nutrition/what-to-eat/images';

  /// Lightweight offline fallback catalog (metadata only; all images are hosted
  /// on the backend and cached to device temp storage on demand).
  static const List<WhatToEatDish> fallbackDishes = [
    // ── BỮA SÁNG ───────────────────────────────────────────────────────────
    WhatToEatDish(
      id: 'pho_bo',
      name: 'Phở bò tái chín',
      mealType: MealTimeCategory.breakfast,
      calories: 460,
      protein: 29,
      carbs: 64,
      fat: 11,
      tagKey: DishTagKey.highProtein,
      emoji: '🍜',
      imageUrl: '$_imageBase/pho_bo.jpg',
    ),
    WhatToEatDish(
      id: 'banh_mi_thit',
      name: 'Bánh mì thịt xíu mại',
      mealType: MealTimeCategory.breakfast,
      calories: 410,
      protein: 20,
      carbs: 48,
      fat: 16,
      tagKey: DishTagKey.quick,
      emoji: '🥖',
      imageUrl: '$_imageBase/banh_mi_thit.jpg',
    ),
    WhatToEatDish(
      id: 'xoi_xeo_ga',
      name: 'Xôi xéo hành phi',
      mealType: MealTimeCategory.breakfast,
      calories: 480,
      protein: 24,
      carbs: 68,
      fat: 14,
      tagKey: DishTagKey.energetic,
      emoji: '🍚',
      imageUrl: '$_imageBase/xoi_xeo_ga.jpg',
    ),
    WhatToEatDish(
      id: 'banh_cuon',
      name: 'Bánh cuốn chả quế',
      mealType: MealTimeCategory.breakfast,
      calories: 360,
      protein: 16,
      carbs: 52,
      fat: 10,
      tagKey: DishTagKey.light,
      emoji: '🥟',
      imageUrl: '$_imageBase/banh_cuon.jpg',
    ),
    WhatToEatDish(
      id: 'bun_bo_hue',
      name: 'Bún bò Huế giò nạc',
      mealType: MealTimeCategory.breakfast,
      calories: 520,
      protein: 34,
      carbs: 58,
      fat: 16,
      tagKey: DishTagKey.highProtein,
      emoji: '🍲',
      imageUrl: '$_imageBase/bun_bo_hue.jpg',
    ),
    WhatToEatDish(
      id: 'hu_tieu_nam_vang',
      name: 'Hủ tiếu Nam Vang sườn tôm',
      mealType: MealTimeCategory.breakfast,
      calories: 430,
      protein: 26,
      carbs: 54,
      fat: 12,
      tagKey: DishTagKey.balanced,
      emoji: '🍜',
      imageUrl: '$_imageBase/hu_tieu_nam_vang.jpg',
    ),
    WhatToEatDish(
      id: 'chao_suon_yen_mach',
      name: 'Cháo sườn yến mạch',
      mealType: MealTimeCategory.breakfast,
      calories: 320,
      protein: 18,
      carbs: 42,
      fat: 8,
      tagKey: DishTagKey.light,
      emoji: '🥣',
      imageUrl: '$_imageBase/chao_suon_yen_mach.jpg',
    ),
    WhatToEatDish(
      id: 'banh_mi_op_la',
      name: 'Bánh mì ốp la 2 trứng',
      mealType: MealTimeCategory.breakfast,
      calories: 380,
      protein: 19,
      carbs: 40,
      fat: 15,
      tagKey: DishTagKey.quick,
      emoji: '🍳',
      imageUrl: '$_imageBase/banh_mi_op_la.jpg',
    ),
    WhatToEatDish(
      id: 'bun_moc',
      name: 'Bún mọc sườn non măng tươi',
      mealType: MealTimeCategory.breakfast,
      calories: 410,
      protein: 27,
      carbs: 50,
      fat: 11,
      tagKey: DishTagKey.light,
      emoji: '🍜',
      imageUrl: '$_imageBase/bun_moc.jpg',
    ),
    WhatToEatDish(
      id: 'mi_quang_ga',
      name: 'Mì Quảng gà trứng cút',
      mealType: MealTimeCategory.breakfast,
      calories: 470,
      protein: 28,
      carbs: 56,
      fat: 15,
      tagKey: DishTagKey.balanced,
      emoji: '🍲',
      imageUrl: '$_imageBase/mi_quang_ga.jpg',
    ),

    // ── BỮA TRƯA ────────────────────────────────────────────────────────────
    WhatToEatDish(
      id: 'com_tam_suon',
      name: 'Cơm tấm sườn nướng trứng',
      mealType: MealTimeCategory.lunch,
      calories: 590,
      protein: 36,
      carbs: 68,
      fat: 18,
      tagKey: DishTagKey.energetic,
      emoji: '🍱',
      imageUrl: '$_imageBase/com_tam_suon.jpg',
    ),
    WhatToEatDish(
      id: 'bun_cha_ha_noi',
      name: 'Bún chả Hà Nội than hoa',
      mealType: MealTimeCategory.lunch,
      calories: 520,
      protein: 31,
      carbs: 62,
      fat: 16,
      tagKey: DishTagKey.balanced,
      emoji: '🥗',
      imageUrl: '$_imageBase/bun_cha_ha_noi.jpg',
    ),
    WhatToEatDish(
      id: 'com_ga_hoi_an',
      name: 'Cơm gà xé Hội An rau răm',
      mealType: MealTimeCategory.lunch,
      calories: 490,
      protein: 33,
      carbs: 58,
      fat: 13,
      tagKey: DishTagKey.highProtein,
      emoji: '🍗',
      imageUrl: '$_imageBase/com_ga_hoi_an.jpg',
    ),
    WhatToEatDish(
      id: 'bun_dau_thit_luoc',
      name: 'Bún đậu thịt luộc chả cốm',
      mealType: MealTimeCategory.lunch,
      calories: 530,
      protein: 29,
      carbs: 55,
      fat: 21,
      tagKey: DishTagKey.balanced,
      emoji: '🥢',
      imageUrl: '$_imageBase/bun_dau_thit_luoc.jpg',
    ),
    WhatToEatDish(
      id: 'com_nieu_ca_kho',
      name: 'Cơm niêu cá kho tộ',
      mealType: MealTimeCategory.lunch,
      calories: 470,
      protein: 30,
      carbs: 60,
      fat: 12,
      tagKey: DishTagKey.balanced,
      emoji: '🐟',
      imageUrl: '$_imageBase/com_nieu_ca_kho.jpg',
    ),
    WhatToEatDish(
      id: 'bun_ca_nha_trang',
      name: 'Bún chả cá Nha Trang thì là',
      mealType: MealTimeCategory.lunch,
      calories: 390,
      protein: 26,
      carbs: 52,
      fat: 9,
      tagKey: DishTagKey.healthy,
      emoji: '🍜',
      imageUrl: '$_imageBase/bun_ca_nha_trang.jpg',
    ),
    WhatToEatDish(
      id: 'com_bo_luc_lac',
      name: 'Cơm bò lúc lắc ớt chuông',
      mealType: MealTimeCategory.lunch,
      calories: 550,
      protein: 35,
      carbs: 58,
      fat: 17,
      tagKey: DishTagKey.highProtein,
      emoji: '🥩',
      imageUrl: '$_imageBase/com_bo_luc_lac.jpg',
    ),
    WhatToEatDish(
      id: 'bun_rieu_cua',
      name: 'Bún riêu cua bắp bò',
      mealType: MealTimeCategory.lunch,
      calories: 460,
      protein: 28,
      carbs: 56,
      fat: 13,
      tagKey: DishTagKey.balanced,
      emoji: '🍲',
      imageUrl: '$_imageBase/bun_rieu_cua.jpg',
    ),
    WhatToEatDish(
      id: 'com_suon_rim',
      name: 'Cơm sườn rim mặn ngọt',
      mealType: MealTimeCategory.lunch,
      calories: 510,
      protein: 32,
      carbs: 62,
      fat: 15,
      tagKey: DishTagKey.balanced,
      emoji: '🍱',
      imageUrl: '$_imageBase/com_suon_rim.jpg',
    ),
    WhatToEatDish(
      id: 'com_ca_hoi_ap_chao',
      name: 'Cơm cá hồi áp chảo măng tây',
      mealType: MealTimeCategory.lunch,
      calories: 490,
      protein: 35,
      carbs: 48,
      fat: 16,
      tagKey: DishTagKey.healthy,
      emoji: '🍣',
      imageUrl: '$_imageBase/com_ca_hoi_ap_chao.jpg',
    ),

    // ── BỮA TỐI ─────────────────────────────────────────────────────────────
    WhatToEatDish(
      id: 'goi_cuon_tom_thit',
      name: 'Gỏi cuốn tôm thịt sốt tương',
      mealType: MealTimeCategory.dinner,
      calories: 320,
      protein: 22,
      carbs: 42,
      fat: 7,
      tagKey: DishTagKey.healthy,
      emoji: '🥗',
      imageUrl: '$_imageBase/goi_cuon_tom_thit.jpg',
    ),
    WhatToEatDish(
      id: 'canh_chua_ca_loc',
      name: 'Canh chua cá lóc + 1/2 bát cơm',
      mealType: MealTimeCategory.dinner,
      calories: 340,
      protein: 28,
      carbs: 38,
      fat: 7,
      tagKey: DishTagKey.light,
      emoji: '🍲',
      imageUrl: '$_imageBase/canh_chua_ca_loc.jpg',
    ),
    WhatToEatDish(
      id: 'canh_kho_qua_nhoi_thit',
      name: 'Canh khổ qua nhồi thịt nạc',
      mealType: MealTimeCategory.dinner,
      calories: 270,
      protein: 24,
      carbs: 20,
      fat: 9,
      tagKey: DishTagKey.light,
      emoji: '🥣',
      imageUrl: '$_imageBase/canh_kho_qua_nhoi_thit.jpg',
    ),
    WhatToEatDish(
      id: 'bo_xao_thien_ly',
      name: 'Bò xào hoa thiên lý',
      mealType: MealTimeCategory.dinner,
      calories: 350,
      protein: 31,
      carbs: 22,
      fat: 14,
      tagKey: DishTagKey.highProtein,
      emoji: '🥩',
      imageUrl: '$_imageBase/bo_xao_thien_ly.jpg',
    ),
    WhatToEatDish(
      id: 'bun_thit_nuong',
      name: 'Bún thịt nướng nhiều rau',
      mealType: MealTimeCategory.dinner,
      calories: 460,
      protein: 26,
      carbs: 58,
      fat: 13,
      tagKey: DishTagKey.balanced,
      emoji: '🍜',
      imageUrl: '$_imageBase/bun_thit_nuong.jpg',
    ),
    WhatToEatDish(
      id: 'lau_nam_ga_tiem',
      name: 'Lẩu nấm gà tiềm thảo mộc',
      mealType: MealTimeCategory.dinner,
      calories: 410,
      protein: 34,
      carbs: 32,
      fat: 12,
      tagKey: DishTagKey.highProtein,
      emoji: '🍲',
      imageUrl: '$_imageBase/lau_nam_ga_tiem.jpg',
    ),
    WhatToEatDish(
      id: 'uc_ga_ap_chao',
      name: 'Ức gà áp chảo sốt tiêu đen',
      mealType: MealTimeCategory.dinner,
      calories: 330,
      protein: 38,
      carbs: 12,
      fat: 10,
      tagKey: DishTagKey.highProtein,
      emoji: '🍗',
      imageUrl: '$_imageBase/uc_ga_ap_chao.jpg',
    ),
    WhatToEatDish(
      id: 'chao_ca_hoi_hat_sen',
      name: 'Cháo cá hồi hạt sen',
      mealType: MealTimeCategory.dinner,
      calories: 310,
      protein: 22,
      carbs: 36,
      fat: 8,
      tagKey: DishTagKey.light,
      emoji: '🥣',
      imageUrl: '$_imageBase/chao_ca_hoi_hat_sen.jpg',
    ),
    WhatToEatDish(
      id: 'salad_uc_ga',
      name: 'Salad ức gà sốt mè rang',
      mealType: MealTimeCategory.dinner,
      calories: 310,
      protein: 32,
      carbs: 16,
      fat: 12,
      tagKey: DishTagKey.healthy,
      emoji: '🥗',
      imageUrl: '$_imageBase/salad_uc_ga.jpg',
    ),
    WhatToEatDish(
      id: 'canh_rong_bien_thit_bo',
      name: 'Canh rong biển đậu hũ thịt bò',
      mealType: MealTimeCategory.dinner,
      calories: 250,
      protein: 26,
      carbs: 14,
      fat: 8,
      tagKey: DishTagKey.healthy,
      emoji: '🍲',
      imageUrl: '$_imageBase/canh_rong_bien_thit_bo.jpg',
    ),
  ];

  static List<WhatToEatDish> getDishesFor(
    MealTimeCategory category, [
    List<WhatToEatDish>? source,
  ]) {
    final list = source ?? fallbackDishes;
    return list.where((d) => d.mealType == category).toList();
  }
}
