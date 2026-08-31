import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/share_card_modal.dart';

class IngredientItem {
  String ten;
  double khoiLuongGram;
  double calo;
  double carb;
  double protein;
  double fat;
  String unit;

  IngredientItem({
    required this.ten,
    required this.khoiLuongGram,
    required this.calo,
    required this.carb,
    required this.protein,
    required this.fat,
    this.unit = 'gr',
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      ten: (json['ten'] ?? json['name'] ?? '').toString(),
      khoiLuongGram:
          (json['khoi_luong_gram'] ?? json['weight_g'] ?? json['gr'] ?? 100)
              .toDouble(),
      calo: (json['calo'] ?? json['calories_kcal'] ?? 0).toDouble(),
      carb: (json['carb'] ?? json['carbs_g'] ?? 0).toDouble(),
      protein: (json['protein'] ?? json['protein_g'] ?? 0).toDouble(),
      fat: (json['fat'] ?? json['fat_g'] ?? 0).toDouble(),
      unit: (json['unit'] ?? 'gr').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ten': ten,
    'khoi_luong_gram': khoiLuongGram,
    'calo': calo,
    'carb': carb,
    'protein': protein,
    'fat': fat,
    'unit': unit,
  };
}

class DishDetailItem {
  String name;
  double weightG;
  double calo;
  double carb;
  double protein;
  double fat;
  List<IngredientItem> ingredients;
  bool expanded;

  DishDetailItem({
    required this.name,
    required this.weightG,
    required this.calo,
    required this.carb,
    required this.protein,
    required this.fat,
    this.ingredients = const [],
    this.expanded = false,
  });

  factory DishDetailItem.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return DishDetailItem(
      name: (json['name'] ?? json['ten_mon'] ?? '').toString(),
      weightG: number('weight_g'),
      calo: number('calo'),
      carb: number('carb'),
      protein: number('protein'),
      fat: number('fat'),
      ingredients: (json['ingredients'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => IngredientItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'weight_g': weightG,
    'calo': calo,
    'carb': carb,
    'protein': protein,
    'fat': fat,
    'ingredients': ingredients.map((item) => item.toJson()).toList(),
  };
}

class ResultScreen extends StatefulWidget {
  final String id;
  const ResultScreen({super.key, required this.id});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;

  String _monChinh = '';
  int _dishCount = 0;
  bool _hasDishCount = false;
  List<String> _detectedDishes = [];
  String? _imageUrl;
  List<IngredientItem> _ingredients = [];
  List<DishDetailItem> _dishDetails = [];
  // Multi-dish responses hide the flattened ingredient list from clients, so
  // keep the server-calculated totals for the result card.
  double _apiTotalCalo = 0;
  double _apiTotalCarb = 0;
  double _apiTotalProtein = 0;
  double _apiTotalFat = 0;
  String? _feedback; // 'like' | 'dislike'
  bool _suggestBarcode = false;
  String? _tipBarcode;

  bool _showDetail = true;
  bool _editingDishName = false;
  final TextEditingController _dishNameController = TextEditingController();

  // Multi-dish is determined only by the VLM dish count. Do not infer it from
  // dish_details or punctuation in mon_chinh; old single-dish scans may have
  // commas in their display name.
  bool get _isMultiDish =>
      _hasDishCount && (_dishCount > 1 || _detectedDishes.length > 1);

  // Feedback modal
  bool _showFeedbackModal = false;
  final TextEditingController _feedbackReasonController =
      TextEditingController();
  bool _submittingFeedback = false;

  @override
  void initState() {
    super.initState();
    _fetchScanDetail();
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _feedbackReasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchScanDetail() async {
    final s = context.read<AppSettingsProvider>().strings;
    setState(() {
      _loading = true;
      _error = null;
    });

    final mockDishes = <String, Map<String, dynamic>>{
      'pho_bo': {
        'mon_chinh': s.mockPhoTitle,
        'image_url':
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800&auto=format&fit=crop&q=80',
        'ingredients': [
          {
            'ten': s.mockPhoNoodles,
            'khoi_luong_gram': 150,
            'calo': 220,
            'carb': 48,
            'protein': 4.5,
            'fat': 1.0,
            'unit': 'g',
          },
          {
            'ten': s.mockPhoRareBeef,
            'khoi_luong_gram': 80,
            'calo': 160,
            'carb': 0,
            'protein': 21.0,
            'fat': 8.0,
            'unit': 'g',
          },
          {
            'ten': s.mockPhoBrisket,
            'khoi_luong_gram': 50,
            'calo': 110,
            'carb': 0,
            'protein': 11.0,
            'fat': 7.0,
            'unit': 'g',
          },
          {
            'ten': s.mockPhoBroth,
            'khoi_luong_gram': 300,
            'calo': 30,
            'carb': 2,
            'protein': 1.5,
            'fat': 1.0,
            'unit': 'ml',
          },
        ],
      },
      'com_tam': {
        'mon_chinh': s.mockRiceTitle,
        'image_url':
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
        'ingredients': [
          {
            'ten': s.mockRice,
            'khoi_luong_gram': 180,
            'calo': 240,
            'carb': 52,
            'protein': 4.5,
            'fat': 1.0,
            'unit': 'g',
          },
          {
            'ten': s.mockGrilledPork,
            'khoi_luong_gram': 120,
            'calo': 310,
            'carb': 5,
            'protein': 24.0,
            'fat': 21.0,
            'unit': 'g',
          },
          {
            'ten': s.mockEggCake,
            'khoi_luong_gram': 60,
            'calo': 115,
            'carb': 3,
            'protein': 7.0,
            'fat': 8.0,
            'unit': 'g',
          },
          {
            'ten': s.mockFriedEgg,
            'khoi_luong_gram': 50,
            'calo': 70,
            'carb': 0.5,
            'protein': 6.0,
            'fat': 5.0,
            'unit': 'g',
          },
        ],
      },
      'salad': {
        'mon_chinh': s.mockSaladTitle,
        'image_url':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop&q=80',
        'ingredients': [
          {
            'ten': s.mockChicken,
            'khoi_luong_gram': 150,
            'calo': 240,
            'carb': 0,
            'protein': 36.0,
            'fat': 4.5,
            'unit': 'g',
          },
          {
            'ten': s.mockSalad,
            'khoi_luong_gram': 120,
            'calo': 25,
            'carb': 5,
            'protein': 1.8,
            'fat': 0.3,
            'unit': 'g',
          },
          {
            'ten': s.mockPassionSauce,
            'khoi_luong_gram': 30,
            'calo': 115,
            'carb': 12,
            'protein': 0.5,
            'fat': 7.5,
            'unit': 'g',
          },
        ],
      },
    };

    try {
      if (mockDishes.containsKey(widget.id) ||
          widget.id == 'demo' ||
          widget.id == 'mock') {
        final mockData = mockDishes[widget.id] ?? mockDishes['pho_bo']!;
        final rawIngs = (mockData['ingredients'] as List? ?? []);
        _monChinh = mockData['mon_chinh'].toString();
        _dishCount = 1;
        _hasDishCount = true;
        _dishNameController.text = _monChinh;
        _imageUrl = mockData['image_url'] as String?;
        _ingredients = rawIngs
            .map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      }

      final api = context.read<ApiService>();
      final data =
          await api
                  .get('/scan/${widget.id}')
                  .timeout(const Duration(seconds: 10))
              as Map<String, dynamic>;

      final rawIngs = (data['ingredients'] as List? ?? []);
      _monChinh = (data['mon_chinh'] ?? '').toString();
      _detectedDishes = (data['dishes'] as List? ?? const [])
          .map((item) => item.toString())
          .where((name) => name.trim().isNotEmpty)
          .toList();
      _dishDetails = (data['dish_details'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => DishDetailItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((dish) => dish.name.trim().isNotEmpty)
          .toList();
      final rawDishCount = data['dish_count'];
      _hasDishCount = rawDishCount is num;
      // Older scan responses without dish_count must keep the legacy
      // single-dish UI, even if other metadata contains multiple names.
      _dishCount = _hasDishCount ? (rawDishCount as num).toInt() : 1;
      // Older records only have dish names. They remain viewable, but new
      // scans include dish_details with weight and nutrition per dish.
      _apiTotalCalo = (data['total_calo'] as num?)?.toDouble() ?? 0;
      _apiTotalCarb = (data['total_carb'] as num?)?.toDouble() ?? 0;
      _apiTotalProtein = (data['total_protein'] as num?)?.toDouble() ?? 0;
      _apiTotalFat = (data['total_fat'] as num?)?.toDouble() ?? 0;
      _dishNameController.text = _monChinh;
      _imageUrl = ApiConfig.resolveMediaUrl(data['image_url']);
      _feedback = data['scan_feedback'] as String?;
      _suggestBarcode = data['suggest_barcode'] == true;
      _tipBarcode = data['tip_barcode'] as String?;
      _ingredients = rawIngs
          .map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        context.read<AuthProvider>().refreshUser();
      }
    } catch (e) {
      _error = 'resultLoadFailed';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double get _totalCalo => _isMultiDish
      ? _apiTotalCalo
      : _ingredients.fold(0, (sum, item) => sum + item.calo);
  double get _totalCarb => _isMultiDish
      ? _apiTotalCarb
      : _ingredients.fold(0, (sum, item) => sum + item.carb);
  double get _totalProtein => _isMultiDish
      ? _apiTotalProtein
      : _ingredients.fold(0, (sum, item) => sum + item.protein);
  double get _totalFat => _isMultiDish
      ? _apiTotalFat
      : _ingredients.fold(0, (sum, item) => sum + item.fat);
  int get _healthScore {
    if (_totalCalo <= 0) return 0;
    var score = 4;
    if (_totalCalo <= 800) score++;
    if (_totalProtein >= 20) score += 2;
    if (_totalCarb <= 100) score++;
    if (_totalFat <= 35) score++;
    if (_ingredients.length >= 2) score++;
    return score.clamp(1, 10);
  }

  void _openShareCard() {
    ShareCardModal.show(
      context,
      CardMemoryData(
        dishName: _monChinh,
        imageUrl: _imageUrl,
        calories: _totalCalo,
        carbs: _totalCarb,
        protein: _totalProtein,
        fat: _totalFat,
      ),
    );
  }

  void _updateGram(int index, double newGram) {
    if (newGram < 0) newGram = 0;
    if (newGram > 2000) newGram = 2000;

    setState(() {
      final ing = _ingredients[index];
      final oldGram = ing.khoiLuongGram <= 0 ? 1 : ing.khoiLuongGram;
      final ratio = newGram / oldGram;

      ing.khoiLuongGram = newGram;
      ing.calo = (ing.calo * ratio).roundToDouble();
      ing.carb = double.parse((ing.carb * ratio).toStringAsFixed(1));
      ing.protein = double.parse((ing.protein * ratio).toStringAsFixed(1));
      ing.fat = double.parse((ing.fat * ratio).toStringAsFixed(1));
    });
  }

  void _updateDishIngredientGram(
    int dishIndex,
    int ingredientIndex,
    double newGram,
  ) {
    if (newGram < 0) newGram = 0;
    if (newGram > 2000) newGram = 2000;
    setState(() {
      final dish = _dishDetails[dishIndex];
      final ingredient = dish.ingredients[ingredientIndex];
      final oldGram = ingredient.khoiLuongGram <= 0
          ? 1
          : ingredient.khoiLuongGram;
      final ratio = newGram / oldGram;
      ingredient.khoiLuongGram = newGram;
      ingredient.calo *= ratio;
      ingredient.carb *= ratio;
      ingredient.protein *= ratio;
      ingredient.fat *= ratio;
      _recalculateDish(dish);
      _recalculateMultiDishTotals();
    });
  }

  void _removeDishIngredient(int dishIndex, int ingredientIndex) {
    if (dishIndex < 0 || dishIndex >= _dishDetails.length) return;
    final dish = _dishDetails[dishIndex];
    if (ingredientIndex < 0 || ingredientIndex >= dish.ingredients.length) {
      return;
    }

    setState(() {
      dish.ingredients.removeAt(ingredientIndex);
      _recalculateDish(dish);
      _recalculateMultiDishTotals();
    });
  }

  void _recalculateDish(DishDetailItem dish) {
    dish.weightG = dish.ingredients.fold(
      0,
      (sum, item) => sum + item.khoiLuongGram,
    );
    dish.calo = dish.ingredients.fold(0, (sum, item) => sum + item.calo);
    dish.carb = dish.ingredients.fold(0, (sum, item) => sum + item.carb);
    dish.protein = dish.ingredients.fold(0, (sum, item) => sum + item.protein);
    dish.fat = dish.ingredients.fold(0, (sum, item) => sum + item.fat);
  }

  void _recalculateMultiDishTotals() {
    _apiTotalCalo = _dishDetails.fold(0, (sum, dish) => sum + dish.calo);
    _apiTotalCarb = _dishDetails.fold(0, (sum, dish) => sum + dish.carb);
    _apiTotalProtein = _dishDetails.fold(0, (sum, dish) => sum + dish.protein);
    _apiTotalFat = _dishDetails.fold(0, (sum, dish) => sum + dish.fat);
  }

  Future<void> _saveDishName() async {
    final newName = _dishNameController.text.trim();
    if (newName.isEmpty || newName == _monChinh) {
      setState(() => _editingDishName = false);
      return;
    }

    setState(() {
      _monChinh = newName;
      _editingDishName = false;
    });

    final api = context.read<ApiService>();
    try {
      await api.patch('/scan/${widget.id}', body: {'mon_chinh': newName});
    } catch (_) {}
  }

  Future<void> _handleFeedback(String type) async {
    final api = context.read<ApiService>();

    if (_feedback == type) {
      setState(() => _feedback = null);
      try {
        await api.patch(
          '/scan/${widget.id}',
          body: {'scan_feedback': null, 'scan_feedback_reason': null},
        );
      } catch (_) {}
      return;
    }

    if (type == 'like') {
      setState(() => _feedback = 'like');
      try {
        await api.patch(
          '/scan/${widget.id}',
          body: {'scan_feedback': 'like', 'scan_feedback_reason': null},
        );
      } catch (_) {}
    } else {
      _feedbackReasonController.clear();
      setState(() {
        _feedback = 'dislike';
        _showFeedbackModal = true;
      });
    }
  }

  Future<void> _submitDislikeReason() async {
    setState(() => _submittingFeedback = true);
    final api = context.read<ApiService>();
    try {
      await api.patch(
        '/scan/${widget.id}',
        body: {
          'scan_feedback': 'dislike',
          'scan_feedback_reason': _feedbackReasonController.text.trim(),
        },
      );
    } catch (_) {}
    if (mounted) {
      setState(() {
        _submittingFeedback = false;
        _showFeedbackModal = false;
      });
    }
  }

  Future<void> _confirmSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    final api = context.read<ApiService>();
    final newName = _dishNameController.text.trim().isNotEmpty
        ? _dishNameController.text.trim()
        : _monChinh;

    try {
      if (!widget.id.startsWith('pho_bo') &&
          !widget.id.startsWith('com_tam') &&
          !widget.id.startsWith('salad') &&
          widget.id != 'demo' &&
          widget.id != 'mock') {
        await api.patch(
          '/scan/${widget.id}',
          body: {
            'mon_chinh': newName,
            'total_calo': _totalCalo.round(),
            'total_carb': _totalCarb,
            'total_protein': _totalProtein,
            'total_fat': _totalFat,
            if (_isMultiDish)
              'dish_details': _dishDetails.map((dish) => dish.toJson()).toList()
            else
              'ingredients': _ingredients.map((ing) => ing.toJson()).toList(),
          },
        );
      }
    } catch (e) {
      debugPrint('Error saving scan results: $e');
    }

    if (mounted) {
      try {
        await context.read<HomeProvider>().loadToday(forceRefresh: true);
      } catch (_) {}
      if (mounted) {
        context.go('/home');
      }
    }
  }

  void _openAddIngredientSheet() {
    final settings = context.read<AppSettingsProvider>();
    final isDark = settings.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddIngredientModal(
        isDark: isDark,
        onAdd: (newItem) {
          setState(() {
            _ingredients.add(newItem);
            _showDetail = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121116) : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF1E1D24) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF2E2D38)
        : const Color(0xFFE2E8F0);
    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? Colors.white : const Color(0xFF2563EB),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  s.resultLoadFailed(widget.id),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textDark, fontSize: 15),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  child: Text(
                    s.scanAgain,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          s.nutritionTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.24),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: _openShareCard,
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Thích',
            onPressed: () => _handleFeedback('like'),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.24),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _feedback == 'like'
                    ? Icons.thumb_up_rounded
                    : Icons.thumb_up_outlined,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Không thích',
            onPressed: () => _handleFeedback('dislike'),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.24),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _feedback == 'dislike'
                    ? Icons.thumb_down_rounded
                    : Icons.thumb_down_outlined,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              if (!_isMultiDish) ...[
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _showDetail = true);
                        _openAddIngredientSheet();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: textDark, width: 1.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: Icon(
                        Icons.auto_fix_high_rounded,
                        size: 18,
                        color: textDark,
                      ),
                      label: Text(
                        s.edit,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _confirmSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          )
                        : Text(
                            s.done,
                            style: TextStyle(
                              color: isDark ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                // ── Full-width food hero ─────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 255,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imageUrl != null && _imageUrl!.isNotEmpty
                          ? Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              cacheWidth: 800,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (_, __, ___) => Container(
                                color: isDark
                                    ? const Color(0xFF292832)
                                    : const Color(0xFFEFF3F2),
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  size: 56,
                                  color: textMuted,
                                ),
                              ),
                            )
                          : Container(
                              color: isDark
                                  ? const Color(0xFF292832)
                                  : const Color(0xFFEFF3F2),
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 56,
                                color: textMuted,
                              ),
                            ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Color(0x66000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (_editingDishName)
                          TextField(
                            controller: _dishNameController,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _saveDishName,
                                icon: const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onSubmitted: (_) => _saveDishName(),
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _monChinh,
                                  style: TextStyle(
                                    fontSize: 20,
                                    height: 1.12,
                                    fontWeight: FontWeight.w900,
                                    color: textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _editingDishName = true),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.edit_rounded,
                                  size: 13,
                                  color: textDark,
                                ),
                                label: Text(
                                  s.edit,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        // ── Enlarged Calorie Card ────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF97316,
                                  ).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFF97316),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.caloriesLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textMuted,
                                    ),
                                  ),
                                  Text(
                                    '${_totalCalo.round()}',
                                    style: TextStyle(
                                      fontSize: 30,
                                      height: 1.05,
                                      fontWeight: FontWeight.w900,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ── Enlarged Macro Cards ─────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _NutrientCard(
                                label: 'Protein',
                                value: _totalProtein,
                                color: const Color(0xFFFB7185),
                                icon: Icons.fitness_center_rounded,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NutrientCard(
                                label: 'Carbs',
                                value: _totalCarb,
                                color: const Color(0xFFF59E0B),
                                icon: Icons.grain_rounded,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NutrientCard(
                                label: 'Fats',
                                value: _totalFat,
                                color: const Color(0xFF3B82F6),
                                icon: Icons.water_drop_rounded,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // ── Enlarged Health Score / Điểm sức khỏe Card ──────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEC4899,
                                  ).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFEC4899),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            s.healthScore,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: textDark,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$_healthScore/10',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: LinearProgressIndicator(
                                        value: _healthScore / 10,
                                        minHeight: 7,
                                        color: const Color(0xFF4ADE80),
                                        backgroundColor: borderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        _MealGuidanceEntryCard(
                          isDark: isDark,
                          onTap: () => context.push('/meal-guidance'),
                        ),
                        if (_suggestBarcode || _tipBarcode != null) ...[
                          const SizedBox(height: 6),
                          _BarcodeTipCard(
                            isDark: isDark,
                            tipText:
                                _tipBarcode ??
                                "Với thực phẩm đóng gói/hộp, bạn hãy thử Quét mã vạch để tra cứu dinh dưỡng chuẩn 100% nhé!",
                            onTap: () => context.push('/barcode-scan'),
                          ),
                        ],
                        const SizedBox(height: 6),

                        // ── Ingredient Detail Drawer (Swipe to Delete) ───────
                        if (_showDetail)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0x33000000)
                                      : const Color(0x0A0F172A),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isMultiDish
                                          ? s.dishesInPhoto
                                          : s.ingredientsInDish,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                    Text(
                                      _isMultiDish
                                          ? s.dishCount(
                                              _dishDetails.isNotEmpty
                                                  ? _dishDetails.length
                                                  : _detectedDishes.length,
                                            )
                                          : s.ingredientCount(
                                              _ingredients.length,
                                            ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _isMultiDish
                                      ? (_dishDetails.isNotEmpty
                                            ? _dishDetails.length
                                            : _detectedDishes.length)
                                      : _ingredients.length,
                                  separatorBuilder: (_, __) =>
                                      Divider(height: 6, color: borderColor),
                                  itemBuilder: (context, idx) {
                                    if (_isMultiDish) {
                                      final dish = _dishDetails.isNotEmpty
                                          ? _dishDetails[idx]
                                          : null;
                                      return Column(
                                        children: [
                                          InkWell(
                                            onTap: dish == null
                                                ? null
                                                : () => setState(
                                                    () => dish.expanded =
                                                        !dish.expanded,
                                                  ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          dish?.name ??
                                                              _detectedDishes[idx],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textDark,
                                                          ),
                                                        ),
                                                        if (dish != null)
                                                          Text(
                                                            s.guidanceDishCalories(
                                                              dish.calo.round(),
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: textMuted,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (dish != null) ...[
                                                    const SizedBox(width: 6),
                                                    Icon(
                                                      dish.expanded
                                                          ? Icons.expand_less
                                                          : Icons.expand_more,
                                                      size: 20,
                                                      color: textMuted,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (dish != null &&
                                              dish.expanded &&
                                              dish.ingredients.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                                bottom: 8,
                                              ),
                                              child: Column(
                                                children: List.generate(dish.ingredients.length, (
                                                  ingredientIndex,
                                                ) {
                                                  final ingredient = dish
                                                      .ingredients[ingredientIndex];
                                                  return Dismissible(
                                                    key: ValueKey(
                                                      'dish_${idx}_${ingredient.ten}_$ingredientIndex',
                                                    ),
                                                    direction: DismissDirection
                                                        .endToStart,
                                                    background: Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 16,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFEF4444,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            s.deleteAction,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(width: 6),
                                                          Icon(
                                                            Icons
                                                                .delete_outline_rounded,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onDismissed: (_) =>
                                                        _removeDishIngredient(
                                                          idx,
                                                          ingredientIndex,
                                                        ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 5,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  ingredient
                                                                      .ten,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color:
                                                                        textDark,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  s.guidanceDishCalories(
                                                                    ingredient
                                                                        .calo
                                                                        .round(),
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color:
                                                                        textMuted,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _updateDishIngredientGram(
                                                                  idx,
                                                                  ingredientIndex,
                                                                  ingredient
                                                                          .khoiLuongGram -
                                                                      5,
                                                                ),
                                                            child: Icon(
                                                              Icons
                                                                  .remove_rounded,
                                                              size: 18,
                                                              color: textDark,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            child: Text(
                                                              '${ingredient.khoiLuongGram.round()}g',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: textDark,
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _updateDishIngredientGram(
                                                                  idx,
                                                                  ingredientIndex,
                                                                  ingredient
                                                                          .khoiLuongGram +
                                                                      5,
                                                                ),
                                                            child: Icon(
                                                              Icons.add_rounded,
                                                              size: 18,
                                                              color: textDark,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                        ],
                                      );
                                    }
                                    final ing = _ingredients[idx];
                                    return Dismissible(
                                      key: ValueKey('${ing.ten}_$idx'),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              s.deleteAction,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      onDismissed: (_) {
                                        setState(
                                          () => _ingredients.removeAt(idx),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ing.ten,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textDark,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${_isMultiDish ? '~' : ''}${s.guidanceDishCalories(ing.calo.round())}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!_isMultiDish)
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => _updateGram(
                                                      idx,
                                                      ing.khoiLuongGram - 5,
                                                    ),
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF2C2A34,
                                                              )
                                                            : const Color(
                                                                0xFFF1F5F9,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.remove_rounded,
                                                        size: 18,
                                                        color: textDark,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                        ),
                                                    child: Text(
                                                      '${ing.khoiLuongGram.round()}g',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: textDark,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () => _updateGram(
                                                      idx,
                                                      ing.khoiLuongGram + 5,
                                                    ),
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF2C2A34,
                                                              )
                                                            : const Color(
                                                                0xFFF1F5F9,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        Icons.add_rounded,
                                                        size: 18,
                                                        color: textDark,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (!_isMultiDish) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: borderColor,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                      ),
                                      onPressed: _openAddIngredientSheet,
                                      icon: Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                        color: textDark,
                                      ),
                                      label: Text(
                                        s.addIngredient,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Dislike Feedback Modal Overlay ──────────────────────
          if (_showFeedbackModal)
            GestureDetector(
              onTap: () => setState(() => _showFeedbackModal = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent taps inside card from closing
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.feedbackThanks,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.feedbackPrompt,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: textMuted),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _feedbackReasonController,
                            maxLines: 3,
                            style: TextStyle(fontSize: 13, color: textDark),
                            decoration: InputDecoration(
                              hintText: s.feedbackHint,
                              hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  // A dislike is useful even without a written
                                  // reason, so persist it when the user skips.
                                  onPressed: _submittingFeedback
                                      ? null
                                      : _submitDislikeReason,
                                  child: Text(
                                    s.skip,
                                    style: TextStyle(color: textMuted),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _submittingFeedback
                                      ? null
                                      : _submitDislikeReason,
                                  child: Text(
                                    _submittingFeedback
                                        ? s.sending
                                        : s.sendFeedback,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MealGuidanceEntryCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _MealGuidanceEntryCard({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final background = isDark ? const Color(0xFF1E1D24) : Colors.white;
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFFA4A2AE) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF2E2D38) : const Color(0xFFE2E8F0);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF30303A)
                      : const Color(0xFFF0F0F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome_outlined, color: text, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.guidanceScreenTitle,
                      style: TextStyle(
                        color: text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.guidanceTodayShortSubtitle,
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: text, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _NutrientCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF9A99A6)
        : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF2E2D38) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D24) : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  s.gramsValue(value.round()),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search & Add Ingredient Modal ──────────────────────────────────────
class _AddIngredientModal extends StatefulWidget {
  final bool isDark;
  final Function(IngredientItem) onAdd;

  const _AddIngredientModal({required this.isDark, required this.onAdd});

  @override
  State<_AddIngredientModal> createState() => _AddIngredientModalState();
}

class _AddIngredientModalState extends State<_AddIngredientModal> {
  final TextEditingController _queryController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _searching = false;
  String? _searchError;
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  int _selectedTabIndex = 0; // 0: Tất cả, 1: Món đã lưu, 2: Món của tôi

  dynamic _selectedHit;
  double _weightG = 100;
  String _selectedUnit = 'gr';
  String _selectedDisplayUnit = 'g';

  static const List<Map<String, dynamic>> _mockNoodleItems = [
    {
      'name': 'Mỳ chính',
      'subtitle': 'Mỳ chính',
      'calories_kcal': 282,
      'protein_g': 0.0,
      'carbs_g': 70.0,
      'fat_g': 0.0,
      'unit': 'g',
      'portion_str': 'g',
    },
    {
      'name': 'Instant noodle, wheat, boiled',
      'subtitle': 'Mỳ ăn liền, lúa mì, luộc',
      'calories_kcal': 102,
      'protein_g': 2.5,
      'carbs_g': 15.0,
      'fat_g': 3.5,
      'unit': 'g',
      'portion_str': 'g',
    },
    {
      'name': 'Wonton soup',
      'subtitle': 'Mỳ vằn thắn',
      'calories_kcal': 473,
      'protein_g': 22.0,
      'carbs_g': 55.0,
      'fat_g': 14.0,
      'unit': 'g',
      'portion_str': 'Phần (666g)',
    },
    {
      'name': 'Wheat noodle soup with wonton',
      'subtitle': 'Mỳ chờ',
      'calories_kcal': 647,
      'protein_g': 28.0,
      'carbs_g': 75.0,
      'fat_g': 18.0,
      'unit': 'g',
      'portion_str': 'Phần (583g)',
    },
    {
      'name': 'Wheat noodle mixed with beef',
      'subtitle': 'Mỳ trộn bò',
      'calories_kcal': 512,
      'protein_g': 32.0,
      'carbs_g': 60.0,
      'fat_g': 16.0,
      'unit': 'g',
      'portion_str': 'Phần (450g)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _queryController.text = 'Mỳ';
    _search('Mỳ');
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _scheduleSearch(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _search(query),
    );
  }

  void _showLocalResults(String query) {
    final queryStr = query.trim();
    if (!mounted) return;
    setState(() {
      if (queryStr.isEmpty) {
        _searchResults = _mockNoodleItems;
      }
      _searching = true;
      _searchError = null;
    });
  }

  Future<void> _search(String q) async {
    final queryStr = q.trim();
    final requestId = ++_searchRequestId;
    if (!mounted) return;

    if (queryStr.isEmpty) {
      setState(() {
        _searchResults = _mockNoodleItems;
        _searching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
    });

    final api = context.read<ApiService>();
    try {
      final res = await api.get(
        '/nutrition/ingredients?q=${Uri.encodeComponent(queryStr)}&limit=10',
      );
      if (res is Map && res['items'] is List) {
        final itemsList = res['items'] as List;
        if (mounted && requestId == _searchRequestId) {
          setState(() {
            if (itemsList.isEmpty && queryStr.toLowerCase().contains('mỳ')) {
              _searchResults = _mockNoodleItems;
            } else {
              _searchResults = itemsList;
            }
            _searching = false;
          });
        }
        return;
      }
    } catch (_) {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _searchError = 'Không thể kết nối máy chủ dinh dưỡng.';
        });
      }
    }

    if (mounted && requestId == _searchRequestId) {
      setState(() {
        final lower = queryStr.toLowerCase();
        final filtered = _mockNoodleItems.where((item) {
          final n = (item['name'] ?? '').toString().toLowerCase();
          final sub = (item['subtitle'] ?? '').toString().toLowerCase();
          return n.contains(lower) || sub.contains(lower);
        }).toList();

        _searchResults = filtered.isNotEmpty ? filtered : _mockNoodleItems;
        _searching = false;
      });
    }
  }

  void _selectIngredientHit(dynamic hit) {
    setState(() {
      _selectedHit = hit;
      _weightG = 100;
      _selectedUnit = (hit['unit'] ?? 'gr').toString();
      _selectedDisplayUnit = hit['unit'] == 'ml' ? 'ml' : 'g';
    });
  }

  void _addSelectedIngredient() {
    final ratio = _weightG / 100.0;
    final s = context.read<AppSettingsProvider>().strings;
    final item = IngredientItem(
      ten: (_selectedHit['name'] ?? _selectedHit['ten'] ?? s.newIngredient)
          .toString(),
      khoiLuongGram: _weightG,
      calo:
          ((_selectedHit['calories_kcal'] ?? _selectedHit['calo'] ?? 0) * ratio)
              .roundToDouble(),
      carb: double.parse(
        ((_selectedHit['carbs_g'] ?? _selectedHit['carb'] ?? 0) * ratio)
            .toStringAsFixed(1),
      ),
      protein: double.parse(
        ((_selectedHit['protein_g'] ?? _selectedHit['protein'] ?? 0) * ratio)
            .toStringAsFixed(1),
      ),
      fat: double.parse(
        ((_selectedHit['fat_g'] ?? _selectedHit['fat'] ?? 0) * ratio)
            .toStringAsFixed(1),
      ),
      unit: _selectedUnit,
    );
    widget.onAdd(item);
    Navigator.pop(context);
  }

  void _showCustomFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController(text: '100');
    final textDark = widget.isDark ? Colors.white : const Color(0xFF0F172A);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:
            widget.isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          'Thêm món thủ công',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: TextStyle(color: textDark),
              decoration: const InputDecoration(
                labelText: 'Tên món ăn',
                hintText: 'Nhập tên món ăn...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: calCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textDark),
              decoration: const InputDecoration(
                labelText: 'Calo (kcal / 100g)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final cal = double.tryParse(calCtrl.text) ?? 100;
                widget.onAdd(
                  IngredientItem(
                    ten: name,
                    khoiLuongGram: 100,
                    calo: cal,
                    carb: 10,
                    protein: 5,
                    fat: 3,
                    unit: 'g',
                  ),
                );
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Thêm ngay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openDescriptionDialog() {
    final descCtrl = TextEditingController();
    final textDark = widget.isDark ? Colors.white : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? const Color(0xFF212027) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_outlined, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Mô tả món ăn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              autofocus: true,
              style: TextStyle(color: textDark),
              decoration: InputDecoration(
                hintText: 'Ví dụ: 1 bát mỳ vằn thắn 450g + 1 quả trứng luộc',
                filled: true,
                fillColor: widget.isDark
                    ? const Color(0xFF2A2932)
                    : const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  final text = descCtrl.text.trim();
                  if (text.isNotEmpty) {
                    widget.onAdd(
                      IngredientItem(
                        ten: text,
                        khoiLuongGram: 200,
                        calo: 350,
                        carb: 45,
                        protein: 15,
                        fat: 10,
                        unit: 'g',
                      ),
                    );
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Tự động phân tích & thêm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVoiceDialog() {
    final textDark = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    bool isListening = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF212027) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nhập món ăn bằng giọng nói',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isListening ? 'Đang lắng nghe...' : 'Đã ghi nhận giọng nói',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark
                      ? const Color(0xFF9A99A6)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  setModalState(() => isListening = !isListening);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isListening
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0F172A))
                            .withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    widget.onAdd(
                      IngredientItem(
                        ten: 'Mỳ vằn thắn (Giọng nói)',
                        khoiLuongGram: 350,
                        calo: 473,
                        carb: 55,
                        protein: 22,
                        fat: 14,
                        unit: 'g',
                      ),
                    );
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Hoàn tất & thêm món',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final textDark = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = widget.isDark ? const Color(0xFF212027) : Colors.white;
    final surface = widget.isDark
        ? const Color(0xFF2A2932)
        : const Color(0xFFF3F4F6);
    final border = widget.isDark
        ? const Color(0xFF383741)
        : const Color(0xFFE2E8F0);
    final textMuted = widget.isDark
        ? const Color(0xFF9A99A6)
        : const Color(0xFF64748B);
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = screenHeight - keyboardHeight;
    final modalHeight = availableHeight.clamp(screenHeight * 0.7, screenHeight * 0.94);

    final displayResults = _searchResults.isNotEmpty
        ? _searchResults
        : _mockNoodleItems;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: modalHeight.toDouble(),
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 10,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top pull handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Header Bar with Back (<), Title (Ghi món ăn), and Add (+)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_selectedHit != null) {
                      setState(() => _selectedHit = null);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: textDark,
                      size: 24,
                    ),
                  ),
                ),
                Text(
                  _selectedHit == null ? 'Ghi món ăn' : s.choosePortion,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                GestureDetector(
                  onTap: _showCustomFoodDialog,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: textDark,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_selectedHit == null) ...[
              // ── Tab Bar (Tất cả, Món đã lưu, Món của tôi) ──────
              Row(
                children: ['Tất cả', 'Món đã lưu', 'Món của tôi']
                    .asMap()
                    .entries
                    .map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isSelected = _selectedTabIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = idx),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 6),
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border(
                                bottom: BorderSide(
                                  color: textDark,
                                  width: 2.5,
                                ),
                              )
                            : null,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? textDark : textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ── Search Input Field ──────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF2A2932)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _queryController,
                  style: TextStyle(fontSize: 15, color: textDark),
                  decoration: InputDecoration(
                    hintText: 'Tìm món ăn hoặc nguyên liệu...',
                    hintStyle: TextStyle(color: textMuted, fontSize: 15),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: textMuted,
                    ),
                    suffixIcon: _queryController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                            onPressed: () {
                              _searchDebounce?.cancel();
                              _queryController.clear();
                              _search('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _showLocalResults(value);
                    _scheduleSearch(value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Section Title: Kết quả tìm kiếm ────────────────
              Text(
                'Kết quả tìm kiếm',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 12),

              // ── Search Results Cards List ───────────────────────
              Expanded(
                child: displayResults.isEmpty
                    ? Center(
                        child: Text(
                          _searching
                              ? 'Đang tìm kiếm...'
                              : (_searchError ?? s.ingredientNotFound),
                          style: TextStyle(color: textMuted),
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: displayResults.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final hit = displayResults[idx];
                          final title =
                              (hit['name'] ?? hit['ten'] ?? '').toString();
                          final subtitle = (hit['subtitle'] ??
                                  hit['vi_name'] ??
                                  hit['aliases']?['vi'] ??
                                  title)
                              .toString();
                          final calories = hit['calories_kcal'] is num
                              ? (hit['calories_kcal'] as num).round()
                              : hit['calo'] is num
                                  ? (hit['calo'] as num).round()
                                  : 0;
                          final portionStr = (hit['portion_str'] ??
                                  (hit['unit'] == 'ml'
                                      ? 'ml'
                                      : hit['unit'] ?? 'g'))
                              .toString();

                          return Material(
                            color: widget.isDark
                                ? const Color(0xFF1E1D24)
                                : const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () => _selectIngredientHit(hit),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            subtitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.local_fire_department_rounded,
                                                size: 15,
                                                color: Color(0xFFF97316),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$calories cal',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: textMuted,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                ),
                                                child: Text(
                                                  '·',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: textMuted,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                portionStr,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // White circular plus button on the right
                                    GestureDetector(
                                      onTap: () => _selectIngredientHit(hit),
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.06),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Color(0xFF0F172A),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // ── Floating Sticky Action Pills Bar (Mô tả & Giọng nói)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _openDescriptionDialog,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF2A2932)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: textDark,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mô tả',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _openVoiceDialog,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF2A2932)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_none_rounded,
                              size: 20,
                              color: textDark,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Giọng nói',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // ── Portion Adjustment Screen ──────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: textDark.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.restaurant_menu_rounded,
                                color: textDark,
                                size: 25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (_selectedHit['name'] ??
                                      _selectedHit['ten'] ??
                                      '')
                                  .toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _WeightButton(
                                  icon: Icons.remove_rounded,
                                  enabled: _weightG > 10,
                                  onTap: () => setState(
                                    () => _weightG = (_weightG - 10).clamp(
                                      10,
                                      1000,
                                    ),
                                  ),
                                  isDark: widget.isDark,
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    _selectedDisplayUnit == 'ml'
                                        ? '${_weightG.round()}ml'
                                        : s.gramsValue(_weightG.round()),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                                _WeightButton(
                                  icon: Icons.add_rounded,
                                  enabled: _weightG < 1000,
                                  onTap: () => setState(
                                    () => _weightG = (_weightG + 10).clamp(
                                      10,
                                      1000,
                                    ),
                                  ),
                                  isDark: widget.isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [50, 100, 150, 200]
                                  .map(
                                    (grams) => Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: grams == 50 ? 0 : 4,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(
                                            _selectedDisplayUnit == 'ml'
                                                ? '${grams}ml'
                                                : s.gramsValue(grams),
                                          ),
                                          selected: _weightG == grams,
                                          showCheckmark: false,
                                          onSelected: (_) => setState(
                                            () => _weightG = grams.toDouble(),
                                          ),
                                          selectedColor: const Color(
                                            0xFF0F172A,
                                          ),
                                          backgroundColor: cardBg,
                                          side: BorderSide(color: border),
                                          labelStyle: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _weightG == grams
                                                ? Colors.white
                                                : textDark,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _NutritionPreview(
                        hit: _selectedHit,
                        weightG: _weightG,
                        isDark: widget.isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedHit = null),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: textDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _addSelectedIngredient,
                        icon: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          s.addIngredient,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeightButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDark;

  const _WeightButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF383741) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class _NutritionPreview extends StatelessWidget {
  final dynamic hit;
  final double weightG;
  final bool isDark;

  const _NutritionPreview({
    required this.hit,
    required this.weightG,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final ratio = weightG / 100;
    final calories = ((hit['calories_kcal'] ?? hit['calo'] ?? 0) * ratio)
        .round();
    final protein = ((hit['protein_g'] ?? hit['protein'] ?? 0) * ratio)
        .toStringAsFixed(1);
    final carbs = ((hit['carbs_g'] ?? hit['carb'] ?? 0) * ratio)
        .toStringAsFixed(1);
    final fat = ((hit['fat_g'] ?? hit['fat'] ?? 0) * ratio).toStringAsFixed(1);
    final surface = isDark ? const Color(0xFF2A2932) : const Color(0xFFF8FAFC);
    final border = isDark ? const Color(0xFF383741) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? const Color(0xFF9A99A6)
        : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _PreviewStat(
            label: s.energyLabel,
            value: '$calories',
            unit: 'kcal',
            color: const Color(0xFFF97316),
            textDark: textDark,
            textMuted: textMuted,
          ),
          _PreviewDivider(color: border),
          _PreviewStat(
            label: s.proteinLabel,
            value: protein,
            unit: 'g',
            color: const Color(0xFF22C55E),
            textDark: textDark,
            textMuted: textMuted,
          ),
          _PreviewDivider(color: border),
          _PreviewStat(
            label: s.carbsLabel,
            value: carbs,
            unit: 'g',
            color: const Color(0xFF3B82F6),
            textDark: textDark,
            textMuted: textMuted,
          ),
          _PreviewDivider(color: border),
          _PreviewStat(
            label: s.fatLabel,
            value: fat,
            unit: 'g',
            color: const Color(0xFFF59E0B),
            textDark: textDark,
            textMuted: textMuted,
          ),
        ],
      ),
    );
  }
}

class _PreviewDivider extends StatelessWidget {
  final Color color;
  const _PreviewDivider({required this.color});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: color);
}

class _PreviewStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final Color textDark;
  final Color textMuted;

  const _PreviewStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(fontSize: 9, color: textMuted),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
              children: [
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeTipCard extends StatelessWidget {
  final bool isDark;
  final String tipText;
  final VoidCallback onTap;

  const _BarcodeTipCard({
    required this.isDark,
    required this.tipText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFBBF7D0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF22C55E),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipText,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Quét mã vạch ngay",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
