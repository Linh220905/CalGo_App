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
  String? _imageUrl;
  List<IngredientItem> _ingredients = [];
  String? _feedback; // 'like' | 'dislike'

  bool _showDetail = true;
  bool _editingDishName = false;
  final TextEditingController _dishNameController = TextEditingController();

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
    setState(() {
      _loading = true;
      _error = null;
    });

    final mockDishes = <String, Map<String, dynamic>>{
      'pho_bo': {
        'mon_chinh': 'Phở Bò Tái Nạm',
        'image_url':
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800&auto=format&fit=crop&q=80',
        'ingredients': [
          {
            'ten': 'Bánh phở tươi',
            'khoi_luong_gram': 150,
            'calo': 220,
            'carb': 48,
            'protein': 4.5,
            'fat': 1.0,
            'unit': 'g'
          },
          {
            'ten': 'Thịt bò tái',
            'khoi_luong_gram': 80,
            'calo': 160,
            'carb': 0,
            'protein': 21.0,
            'fat': 8.0,
            'unit': 'g'
          },
          {
            'ten': 'Thịt nạm bò',
            'khoi_luong_gram': 50,
            'calo': 110,
            'carb': 0,
            'protein': 11.0,
            'fat': 7.0,
            'unit': 'g'
          },
          {
            'ten': 'Nước dùng phở & Hành lá',
            'khoi_luong_gram': 300,
            'calo': 30,
            'carb': 2,
            'protein': 1.5,
            'fat': 1.0,
            'unit': 'ml'
          },
        ],
      },
      'com_tam': {
        'mon_chinh': 'Cơm Tấm Sườn Bì Chả',
        'image_url':
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
        'ingredients': [
          {
            'ten': 'Cơm tấm',
            'khoi_luong_gram': 180,
            'calo': 240,
            'carb': 52,
            'protein': 4.5,
            'fat': 1.0,
            'unit': 'g'
          },
          {
            'ten': 'Sườn heo nướng',
            'khoi_luong_gram': 120,
            'calo': 310,
            'carb': 5,
            'protein': 24.0,
            'fat': 21.0,
            'unit': 'g'
          },
          {
            'ten': 'Chả trứng hấp',
            'khoi_luong_gram': 60,
            'calo': 115,
            'carb': 3,
            'protein': 7.0,
            'fat': 8.0,
            'unit': 'g'
          },
          {
            'ten': 'Trứng ốp la',
            'khoi_luong_gram': 50,
            'calo': 70,
            'carb': 0.5,
            'protein': 6.0,
            'fat': 5.0,
            'unit': 'g'
          },
        ],
      },
      'salad': {
        'mon_chinh': 'Salad Ức Gà Sốt Chanh Dây',
        'image_url':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop&q=80',
        'ingredients': [
          {
            'ten': 'Ức gà áp chảo',
            'khoi_luong_gram': 150,
            'calo': 240,
            'carb': 0,
            'protein': 36.0,
            'fat': 4.5,
            'unit': 'g'
          },
          {
            'ten': 'Xà lách & Cà chua chery',
            'khoi_luong_gram': 120,
            'calo': 25,
            'carb': 5,
            'protein': 1.8,
            'fat': 0.3,
            'unit': 'g'
          },
          {
            'ten': 'Sốt chanh dây',
            'khoi_luong_gram': 30,
            'calo': 115,
            'carb': 12,
            'protein': 0.5,
            'fat': 7.5,
            'unit': 'g'
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
        _dishNameController.text = _monChinh;
        _imageUrl = mockData['image_url'] as String?;
        _ingredients = rawIngs
            .map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      }

      final api = context.read<ApiService>();
      final data = await api.get('/scan/${widget.id}').timeout(
            const Duration(seconds: 10),
          ) as Map<String, dynamic>;

      final rawIngs = (data['ingredients'] as List? ?? []);
      _monChinh = (data['mon_chinh'] ?? 'Món ăn').toString();
      _dishNameController.text = _monChinh;
      _imageUrl = ApiConfig.resolveMediaUrl(data['image_url']);
      _feedback = data['scan_feedback'] as String?;
      _ingredients = rawIngs
          .map((e) => IngredientItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        context.read<AuthProvider>().refreshUser();
      }
    } catch (e) {
      _error =
          'Không thể tải kết quả phân tích (ID: ${widget.id}). Vui lòng thử lại!';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  double get _totalCalo => _ingredients.fold(0, (sum, item) => sum + item.calo);
  double get _totalCarb => _ingredients.fold(0, (sum, item) => sum + item.carb);
  double get _totalProtein =>
      _ingredients.fold(0, (sum, item) => sum + item.protein);
  double get _totalFat => _ingredients.fold(0, (sum, item) => sum + item.fat);
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
        await api.patch('/scan/${widget.id}', body: {'scan_feedback': null});
      } catch (_) {}
      return;
    }

    if (type == 'like') {
      setState(() => _feedback = 'like');
      try {
        await api.patch('/scan/${widget.id}', body: {'scan_feedback': 'like'});
      } catch (_) {}
    } else {
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
      await api.patch('/scan/${widget.id}', body: {
        'scan_feedback': 'dislike',
        'scan_feedback_reason': _feedbackReasonController.text.trim(),
      });
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
        await api.patch('/scan/${widget.id}', body: {
          'mon_chinh': newName,
          'total_calo': _totalCalo.round(),
          'total_carb': _totalCarb,
          'total_protein': _totalProtein,
          'total_fat': _totalFat,
          'ingredients': _ingredients.map((ing) => ing.toJson()).toList(),
        });
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
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121116) : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF1E1D24) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF2E2D38) : const Color(0xFFE2E8F0);
    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(
              color: isDark ? Colors.white : const Color(0xFF2563EB)),
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
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: Color(0xFFEF4444)),
                const SizedBox(height: 16),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textDark, fontSize: 15)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/scan'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB)),
                  child: const Text('Quét lại',
                      style: TextStyle(color: Colors.white)),
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
        title: const Text('Dinh dưỡng',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
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
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
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
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
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
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: Icon(Icons.auto_fix_high_rounded,
                        size: 18, color: textDark),
                    label: Text('Chỉnh sửa',
                        style: TextStyle(
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _confirmSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.white : const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
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
                        : Text('Xong',
                            style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800)),
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
                  height: 310,
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
                                child: Icon(Icons.restaurant_rounded,
                                    size: 56, color: textMuted),
                              ),
                            )
                          : Container(
                              color: isDark
                                  ? const Color(0xFF292832)
                                  : const Color(0xFFEFF3F2),
                              child: Icon(Icons.restaurant_rounded,
                                  size: 56, color: textMuted),
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
                      // Share FAB on food image hero — matching web exactly
                      Positioned(
                        right: 16,
                        bottom: 40,
                        child: GestureDetector(
                          onTap: _openShareCard,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bookmark_border_rounded,
                                size: 20, color: textDark),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2A34)
                                    : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text('Kết quả AI',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: textMuted)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_editingDishName)
                          TextField(
                            controller: _dishNameController,
                            autofocus: true,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textDark),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _saveDishName,
                                icon: const Icon(Icons.check_rounded,
                                    color: Color(0xFF16A34A)),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
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
                                    fontSize: 22,
                                    height: 1.12,
                                    fontWeight: FontWeight.w900,
                                    color: textDark,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    setState(() => _editingDishName = true),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 9),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: Icon(Icons.edit_rounded,
                                    size: 14, color: textDark),
                                label: Text('Sửa',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: textDark)),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF97316).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: Color(0xFFF97316),
                                    size: 22),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Calories',
                                      style: TextStyle(
                                          fontSize: 11, color: textMuted)),
                                  Text('${_totalCalo.round()}',
                                      style: TextStyle(
                                          fontSize: 26,
                                          height: 1.05,
                                          fontWeight: FontWeight.w900,
                                          color: textDark)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_rounded,
                                  color: Color(0xFFEC4899), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('Điểm cân bằng',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: textDark)),
                                        ),
                                        Text('$_healthScore/10',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                                color: textDark)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: LinearProgressIndicator(
                                        value: _healthScore / 10,
                                        minHeight: 5,
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
                        const SizedBox(height: 28),

                        // ── Ingredient Detail Drawer (Swipe to Delete) ───────
                        if (_showDetail)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0x33000000)
                                      : const Color(0x0A0F172A),
                                  blurRadius: 16,
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
                                      'Thành phần món ăn',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: textDark),
                                    ),
                                    Text(
                                      '${_ingredients.length} nguyên liệu',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _ingredients.length,
                                  separatorBuilder: (_, __) =>
                                      Divider(height: 16, color: borderColor),
                                  itemBuilder: (context, idx) {
                                    final ing = _ingredients[idx];
                                    return Dismissible(
                                      key: ValueKey('${ing.ten}_$idx'),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Xóa',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                            SizedBox(width: 6),
                                            Icon(Icons.delete_outline_rounded,
                                                color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                      onDismissed: (_) {
                                        setState(
                                            () => _ingredients.removeAt(idx));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(ing.ten,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: textDark)),
                                                  Text(
                                                      '${ing.calo.round()} kcal',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: textMuted)),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () => _updateGram(idx,
                                                      ing.khoiLuongGram - 5),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF2C2A34)
                                                          : const Color(
                                                              0xFFF1F5F9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Icon(
                                                        Icons.remove_rounded,
                                                        size: 18,
                                                        color: textDark),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    '${ing.khoiLuongGram.round()}g',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: textDark),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => _updateGram(idx,
                                                      ing.khoiLuongGram + 5),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF2C2A34)
                                                          : const Color(
                                                              0xFFF1F5F9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Icon(
                                                        Icons.add_rounded,
                                                        size: 18,
                                                        color: textDark),
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
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: borderColor, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                    onPressed: _openAddIngredientSheet,
                                    icon: Icon(Icons.add_rounded,
                                        size: 20, color: textDark),
                                    label: Text(
                                      'Thêm nguyên liệu',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 40),
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
                          Text('Cảm ơn bạn đã góp ý!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textDark)),
                          const SizedBox(height: 6),
                          Text(
                            'AI scan chưa chính xác? Hãy cho chúng tôi biết chi tiết:',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: textMuted),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _feedbackReasonController,
                            maxLines: 3,
                            style: TextStyle(fontSize: 13, color: textDark),
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: Sai tên món, thiếu rau...',
                              hintStyle:
                                  TextStyle(color: textMuted, fontSize: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(
                                      () => _showFeedbackModal = false),
                                  child: Text('Bỏ qua',
                                      style: TextStyle(color: textMuted)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: _submittingFeedback
                                      ? null
                                      : _submitDislikeReason,
                                  child: Text(
                                      _submittingFeedback
                                          ? 'Đang gửi...'
                                          : 'Gửi góp ý',
                                      style:
                                          const TextStyle(color: Colors.white)),
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
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF9A99A6) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF2E2D38) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1D24) : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    style: TextStyle(fontSize: 9, color: textMuted)),
                Text('${value.round()}g',
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textDark)),
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
  Timer? _searchDebounce;
  int _searchRequestId = 0;

  dynamic _selectedHit;
  double _weightG = 100;

  static const List<Map<String, dynamic>> _fallbackIngredients = [
    {
      'name': 'Thịt bò tươi',
      'calories_kcal': 200,
      'protein_g': 26.0,
      'carbs_g': 0.0,
      'fat_g': 10.0,
      'unit': 'g'
    },
    {
      'name': 'Ức gà áp chảo',
      'calories_kcal': 165,
      'protein_g': 31.0,
      'carbs_g': 0.0,
      'fat_g': 3.6,
      'unit': 'g'
    },
    {
      'name': 'Trứng gà',
      'calories_kcal': 155,
      'protein_g': 13.0,
      'carbs_g': 1.1,
      'fat_g': 11.0,
      'unit': 'quả'
    },
    {
      'name': 'Bánh phở tươi',
      'calories_kcal': 146,
      'protein_g': 3.0,
      'carbs_g': 32.0,
      'fat_g': 0.7,
      'unit': 'g'
    },
    {
      'name': 'Cơm trắng',
      'calories_kcal': 130,
      'protein_g': 2.7,
      'carbs_g': 28.0,
      'fat_g': 0.3,
      'unit': 'g'
    },
    {
      'name': 'Bún tươi',
      'calories_kcal': 110,
      'protein_g': 1.7,
      'carbs_g': 25.0,
      'fat_g': 0.2,
      'unit': 'g'
    },
    {
      'name': 'Xà lách & Cà chua',
      'calories_kcal': 20,
      'protein_g': 1.2,
      'carbs_g': 4.0,
      'fat_g': 0.2,
      'unit': 'g'
    },
    {
      'name': 'Phô mai Cheddar',
      'calories_kcal': 402,
      'protein_g': 25.0,
      'carbs_g': 1.3,
      'fat_g': 33.0,
      'unit': 'g'
    },
    {
      'name': 'Sốt chanh dây',
      'calories_kcal': 380,
      'protein_g': 1.0,
      'carbs_g': 40.0,
      'fat_g': 25.0,
      'unit': 'ml'
    },
    {
      'name': 'Thịt nạc heo',
      'calories_kcal': 242,
      'protein_g': 27.0,
      'carbs_g': 0.0,
      'fat_g': 14.0,
      'unit': 'g'
    },
  ];

  @override
  void initState() {
    super.initState();
    _search('');
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
      const Duration(milliseconds: 280),
      () => _search(query),
    );
  }

  Future<void> _search(String q) async {
    final queryStr = q.trim();
    final requestId = ++_searchRequestId;
    setState(() => _searching = true);

    final api = context.read<ApiService>();
    try {
      final res = await api
          .get('/nutrition/ingredients?q=${Uri.encodeComponent(queryStr)}');
      if (res is Map && res['items'] is List) {
        final itemsList = res['items'] as List;
        if (mounted && requestId == _searchRequestId) {
          setState(() {
            _searchResults = itemsList;
            _searching = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted && requestId == _searchRequestId) {
      setState(() {
        if (queryStr.isEmpty) {
          _searchResults = _fallbackIngredients;
        } else {
          final lower = queryStr.toLowerCase();
          _searchResults = _fallbackIngredients.where((item) {
            final name =
                (item['name'] ?? item['ten'] ?? '').toString().toLowerCase();
            return name.contains(lower);
          }).toList();
        }
        _searching = false;
      });
    }
  }

  void _addSelectedIngredient() {
    final ratio = _weightG / 100.0;
    final item = IngredientItem(
      ten: (_selectedHit['name'] ?? _selectedHit['ten'] ?? 'Thành phần mới')
          .toString(),
      khoiLuongGram: _weightG,
      calo:
          ((_selectedHit['calories_kcal'] ?? _selectedHit['calo'] ?? 0) * ratio)
              .roundToDouble(),
      carb: double.parse(
          ((_selectedHit['carbs_g'] ?? _selectedHit['carb'] ?? 0) * ratio)
              .toStringAsFixed(1)),
      protein: double.parse(
          ((_selectedHit['protein_g'] ?? _selectedHit['protein'] ?? 0) * ratio)
              .toStringAsFixed(1)),
      fat: double.parse(
          ((_selectedHit['fat_g'] ?? _selectedHit['fat'] ?? 0) * ratio)
              .toStringAsFixed(1)),
    );
    widget.onAdd(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textDark = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = widget.isDark ? const Color(0xFF212027) : Colors.white;
    final surface =
        widget.isDark ? const Color(0xFF2A2932) : const Color(0xFFF8FAFC);
    final border =
        widget.isDark ? const Color(0xFF383741) : const Color(0xFFE2E8F0);
    final textMuted =
        widget.isDark ? const Color(0xFF9A99A6) : const Color(0xFF64748B);
    final accent = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = MediaQuery.sizeOf(context).height - keyboardHeight;

    return Container(
      height: availableHeight * 0.88,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedHit == null
                          ? 'Thêm nguyên liệu'
                          : 'Chọn khẩu phần',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedHit == null
                          ? 'Tìm trong thư viện dinh dưỡng'
                          : 'Điều chỉnh khối lượng trước khi thêm',
                      style: TextStyle(fontSize: 12, color: textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: surface,
                  minimumSize: const Size(40, 40),
                ),
                icon: Icon(Icons.close_rounded, color: textDark, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_selectedHit == null) ...[
            TextField(
              controller: _queryController,
              autofocus: true,
              style: TextStyle(fontSize: 14, color: textDark),
              decoration: InputDecoration(
                hintText: 'Tìm thịt bò, trứng, cơm...',
                hintStyle: TextStyle(color: textMuted),
                prefixIcon:
                    Icon(Icons.search_rounded, size: 21, color: textMuted),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _queryController.clear();
                          _search('');
                        },
                        icon: Icon(Icons.cancel_rounded,
                            size: 18, color: textMuted),
                      )
                    : null,
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _scheduleSearch(value);
              },
            ),
            SizedBox(
              height: 3,
              child: _searching
                  ? LinearProgressIndicator(
                      color: accent,
                      backgroundColor: Colors.transparent,
                    )
                  : null,
            ),
            const SizedBox(height: 9),
            Expanded(
              child: _searchResults.isEmpty && !_searching
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search_off_rounded,
                                color: textMuted, size: 27),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không tìm thấy nguyên liệu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thử một tên ngắn hoặc phổ biến hơn',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final hit = _searchResults[idx];
                        final calories =
                            hit['calories_kcal'] ?? hit['calo'] ?? 0;
                        return Material(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => setState(() => _selectedHit = hit),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: textDark.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(Icons.restaurant_menu_rounded,
                                        color: textDark, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (hit['name'] ?? hit['ten'] ?? '')
                                              .toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '$calories kcal / 100g',
                                          style: TextStyle(
                                              fontSize: 11, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded,
                                      color: textMuted, size: 21),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
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
                            child: Icon(Icons.restaurant_menu_rounded,
                                color: textDark, size: 25),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            (_selectedHit['name'] ?? _selectedHit['ten'] ?? '')
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
                                onTap: () => setState(() =>
                                    _weightG = (_weightG - 10).clamp(10, 1000)),
                                isDark: widget.isDark,
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '${_weightG.round()} g',
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
                                onTap: () => setState(() =>
                                    _weightG = (_weightG + 10).clamp(10, 1000)),
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
                                          left: grams == 50 ? 0 : 4),
                                      child: ChoiceChip(
                                        label: Text('${grams}g'),
                                        selected: _weightG == grams,
                                        showCheckmark: false,
                                        onSelected: (_) => setState(
                                            () => _weightG = grams.toDouble()),
                                        selectedColor: const Color(0xFF0F172A),
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
                          borderRadius: BorderRadius.circular(16)),
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
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _addSelectedIngredient,
                      icon: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Thêm nguyên liệu',
                        style: TextStyle(
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
    final ratio = weightG / 100;
    final calories =
        ((hit['calories_kcal'] ?? hit['calo'] ?? 0) * ratio).round();
    final protein =
        ((hit['protein_g'] ?? hit['protein'] ?? 0) * ratio).toStringAsFixed(1);
    final carbs =
        ((hit['carbs_g'] ?? hit['carb'] ?? 0) * ratio).toStringAsFixed(1);
    final fat = ((hit['fat_g'] ?? hit['fat'] ?? 0) * ratio).toStringAsFixed(1);
    final surface = isDark ? const Color(0xFF2A2932) : const Color(0xFFF8FAFC);
    final border = isDark ? const Color(0xFF383741) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF9A99A6) : const Color(0xFF64748B);

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
              label: 'Năng lượng',
              value: '$calories',
              unit: 'kcal',
              color: const Color(0xFFF97316),
              textDark: textDark,
              textMuted: textMuted),
          _PreviewDivider(color: border),
          _PreviewStat(
              label: 'Protein',
              value: protein,
              unit: 'g',
              color: const Color(0xFF22C55E),
              textDark: textDark,
              textMuted: textMuted),
          _PreviewDivider(color: border),
          _PreviewStat(
              label: 'Carbs',
              value: carbs,
              unit: 'g',
              color: const Color(0xFF3B82F6),
              textDark: textDark,
              textMuted: textMuted),
          _PreviewDivider(color: border),
          _PreviewStat(
              label: 'Fat',
              value: fat,
              unit: 'g',
              color: const Color(0xFFF59E0B),
              textDark: textDark,
              textMuted: textMuted),
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
          Text(label,
              maxLines: 1, style: TextStyle(fontSize: 9, color: textMuted)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: color),
              children: [
                TextSpan(
                  text: unit,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
