import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/what_to_eat_dish.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../services/what_to_eat_service.dart';

class WhatToEatModal extends StatefulWidget {
  final bool isDark;

  const WhatToEatModal({super.key, required this.isDark});

  static Future<void> show(BuildContext context, {required bool isDark}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WhatToEatModal(isDark: isDark),
    );
  }

  @override
  State<WhatToEatModal> createState() => _WhatToEatModalState();
}

class _WhatToEatModalState extends State<WhatToEatModal> {
  late MealTimeCategory _selectedMeal;
  late List<WhatToEatDish> _allDishes;
  late List<WhatToEatDish> _dishes;
  late ScrollController _scrollController;
  bool _isSpinning = false;
  int _lastHapticIndex = -1;

  static const double _cardWidth = 140.0;
  static const double _cardHeight = 194.0;
  static const double _cardSpacing = 12.0;
  static const double _itemExtent = _cardWidth + _cardSpacing; // 152.0
  static const int _reelRepeats = 12;

  @override
  void initState() {
    super.initState();
    _selectedMeal = WhatToEatDish.currentMealCategory();
    _allDishes = WhatToEatService.instance.getCachedDishes();
    _dishes = WhatToEatDish.getDishesFor(_selectedMeal, _allDishes);
    final initialOffset = _dishes.isNotEmpty ? _dishes.length * _itemExtent : 0.0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients && _dishes.isNotEmpty) {
        final target = _dishes.length * _itemExtent;
        if ((_scrollController.offset - target).abs() > 0.5) {
          _scrollController.jumpTo(target);
        }
      }
      if (mounted) {
        unawaited(_syncCatalogFromServer());
      }
    });
  }

  Future<void> _syncCatalogFromServer() async {
    String locale = 'vi';
    try {
      locale = context.read<AppSettingsProvider>().languageCode;
    } catch (_) {}

    final service = WhatToEatService.instance;
    final persisted = await service.loadPersistedDishes(locale: locale);
    _applyCatalogIfIdle(persisted);

    final fresh = await service.fetchDishes(locale: locale);
    _applyCatalogIfIdle(fresh);

    if (mounted) {
      unawaited(service.prefetchImages(_dishes));
    }
  }

  void _applyCatalogIfIdle(List<WhatToEatDish> catalog) {
    if (!mounted || catalog.isEmpty) return;
    final nextMealDishes = WhatToEatDish.getDishesFor(_selectedMeal, catalog);
    final changed =
        nextMealDishes.length != _dishes.length ||
        !_sameDishIds(nextMealDishes, _dishes);
    _allDishes = catalog;
    if (!changed || _isSpinning || nextMealDishes.isEmpty) return;
    setState(() {
      _dishes = nextMealDishes;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_dishes.length * _itemExtent);
    }
  }

  bool _sameDishIds(List<WhatToEatDish> a, List<WhatToEatDish> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].name != b[i].name ||
          a[i].imageUrl != b[i].imageUrl) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isSpinning || !_scrollController.hasClients) return;
    final idx = (_scrollController.offset / _itemExtent).round();
    if (idx != _lastHapticIndex) {
      _lastHapticIndex = idx;
      HapticFeedback.selectionClick();
    }
  }

  void _onMealTabChanged(MealTimeCategory category) {
    if (_isSpinning || _selectedMeal == category) return;
    setState(() {
      _selectedMeal = category;
      _dishes = WhatToEatDish.getDishesFor(category, _allDishes);
    });
    if (_scrollController.hasClients && _dishes.isNotEmpty) {
      _scrollController.jumpTo(_dishes.length * _itemExtent);
    }
    unawaited(WhatToEatService.instance.prefetchImages(_dishes));
  }

  Future<void> _spinReel() async {
    if (_isSpinning || _dishes.isEmpty) return;
    setState(() => _isSpinning = true);

    final random = Random();
    final currentCenteredIndex = _scrollController.hasClients
        ? ((_scrollController.offset / _itemExtent).round() % _dishes.length)
        : 0;

    if (_scrollController.hasClients) {
      final normalizedOffset =
          (_dishes.length + currentCenteredIndex) * _itemExtent;
      _scrollController.jumpTo(normalizedOffset);
      _lastHapticIndex = _dishes.length + currentCenteredIndex;
    } else {
      _lastHapticIndex = -1;
    }

    var winningIndex = random.nextInt(_dishes.length);
    if (_dishes.length > 1 && winningIndex == currentCenteredIndex) {
      winningIndex =
          (winningIndex + 1 + random.nextInt(_dishes.length - 1)) %
          _dishes.length;
    }
    final chosen = _dishes[winningIndex];

    const targetRepeat = 7;
    final totalItemIndex = (targetRepeat * _dishes.length) + winningIndex;
    final targetOffset = totalItemIndex * _itemExtent;

    try {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 3000),
          curve: Curves.easeOutQuart,
        );
      }
      if (mounted) {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isSpinning = false);
      }
    }

    if (mounted) {
      _showResultPopup(chosen);
    }
  }

  void _showResultPopup(WhatToEatDish dish) {
    final outerBg = widget.isDark ? const Color(0xFF1A1922) : Colors.white;
    showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogCtx, _, __) => _DishResultDialog(
        dish: dish,
        isDark: widget.isDark,
        onSpinAgain: () {
          Navigator.of(dialogCtx).pop();
          _spinReel();
        },
        onScanMeal: () {
          final router = GoRouter.maybeOf(context);
          Navigator.of(dialogCtx).pop();
          if (mounted) {
            Navigator.of(context).pop();
          }
          router?.push('/scan');
        },
      ),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: outerBg.withValues(alpha: 0.0),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final isDark = widget.isDark;

    final bgColor = isDark ? const Color(0xFF1A1922) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final repeatedItems = <WhatToEatDish>[];
    for (int i = 0; i < _reelRepeats; i++) {
      repeatedItems.addAll(_dishes);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B394A)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '🍲',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.whatToEatTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: textMuted, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Meal Category Tabs (Breakfast, Lunch, Dinner)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262432)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildMealTab(
                        label: s.mealBreakfast,
                        category: MealTimeCategory.breakfast,
                        icon: '🌅',
                        isDark: isDark,
                      ),
                      _buildMealTab(
                        label: s.mealLunch,
                        category: MealTimeCategory.lunch,
                        icon: '☀️',
                        isDark: isDark,
                      ),
                      _buildMealTab(
                        label: s.mealDinner,
                        category: MealTimeCategory.dinner,
                        icon: '🌙',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Edge-to-edge Horizontal Reel Strip with pixel-accurate Center Indicator
              LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = constraints.maxWidth;
                  final sidePad =
                      ((viewportWidth - _cardWidth) / 2).clamp(0.0, double.infinity);

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect rect) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.11, 0.89, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: IgnorePointer(
                          child: SizedBox(
                            height: _cardHeight + 8,
                            child: ListView.separated(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: sidePad,
                              ),
                              itemCount: repeatedItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: _cardSpacing),
                              itemBuilder: (context, index) {
                                final dish = repeatedItems[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: _DishCard(
                                    dish: dish,
                                    strings: s,
                                    isDark: isDark,
                                    width: _cardWidth,
                                    height: _cardHeight,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Center Target Indicator
                      IgnorePointer(
                        child: SizedBox(
                          width: _cardWidth + 10,
                          height: _cardHeight + 12,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFF97316),
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              const Positioned(
                                top: 0,
                                child: CustomPaint(
                                  size: Size(14, 8),
                                  painter: _TrianglePainter(
                                    color: Color(0xFFF97316),
                                    pointingDown: true,
                                  ),
                                ),
                              ),
                              const Positioned(
                                bottom: 0,
                                child: CustomPaint(
                                  size: Size(14, 8),
                                  painter: _TrianglePainter(
                                    color: Color(0xFFF97316),
                                    pointingDown: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),

              // Spin CTA Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSpinning ? null : _spinReel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFF97316).withValues(alpha: 0.5),
                      minimumSize: const Size(double.infinity, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSpinning
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🎲', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                s.spinRandomAction,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

  Widget _buildMealTab({
    required String label,
    required MealTimeCategory category,
    required String icon,
    required bool isDark,
  }) {
    final selected = _selectedMeal == category;
    final activeBg = isDark ? const Color(0xFF332F42) : Colors.white;
    final activeText = isDark ? Colors.white : const Color(0xFF0F172A);
    final inactiveText =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onMealTabChanged(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? activeText : inactiveText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointingDown;

  const _TrianglePainter({
    required this.color,
    required this.pointingDown,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    if (pointingDown) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    } else {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointingDown != pointingDown;
}

class _DishCard extends StatelessWidget {
  final WhatToEatDish dish;
  final AppLocalizations strings;
  final bool isDark;
  final double width;
  final double height;

  const _DishCard({
    required this.dish,
    required this.strings,
    required this.isDark,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF262333) : const Color(0xFFF8FAFC);
    final border = isDark ? const Color(0xFF373449) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top full-bleed dish image + dark-glass kcal badge
              SizedBox(
                height: 118,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _RemoteDishImage(
                      imageUrl: dish.resolvedImageUrl,
                      cacheWidth: 360,
                      fallbackBuilder: _fallbackEmojiBox,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          strings.guidanceDishCalories(dish.calories),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dish Name & Localized Tag
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        dish.localizedTag(strings),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _fallbackEmojiBox() {
    return Container(
      color: const Color(0xFFF97316).withValues(alpha: 0.12),
      child: Center(
        child: Text(
          dish.emoji,
          style: const TextStyle(fontSize: 36),
        ),
      ),
    );
  }
}

class _DishResultDialog extends StatelessWidget {
  final WhatToEatDish dish;
  final bool isDark;
  final VoidCallback onSpinAgain;
  final VoidCallback onScanMeal;

  const _DishResultDialog({
    required this.dish,
    required this.isDark,
    required this.onSpinAgain,
    required this.onScanMeal,
  });

  String _mealLabel(MealTimeCategory mealType, AppLocalizations s) =>
      switch (mealType) {
        MealTimeCategory.breakfast => s.mealBreakfast,
        MealTimeCategory.lunch => s.mealLunch,
        MealTimeCategory.dinner => s.mealDinner,
      };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final bgColor = isDark ? const Color(0xFF1E1C27) : Colors.white;
    final stripBg =
        isDark ? const Color(0xFF262432) : const Color(0xFFF8FAFC);
    final stripBorder =
        isDark ? const Color(0xFF373449) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final tagBg = isDark ? const Color(0xFF2A2738) : const Color(0xFFF1F5F9);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hero Dish Image with top badges & meal label
                      SizedBox(
                        width: double.infinity,
                        height: 215,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _RemoteDishImage(
                              imageUrl: dish.resolvedImageUrl,
                              cacheWidth: 720,
                              fallbackBuilder: _fallbackHeroEmoji,
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.36),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  s.selectedDishTitle,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.52),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _mealLabel(dish.mealType, s),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Body Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dish.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tag pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: tagBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dish.localizedTag(s),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4-Column Equal-Width Nutrition Strip (zero overflow!)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: stripBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: stripBorder),
                              ),
                              child: Row(
                                children: [
                                  _buildNutritionCol(
                                    value: '${dish.calories}',
                                    label: s.kcalSuffix,
                                    accent: const Color(0xFFF97316),
                                    textDark: textDark,
                                    textMuted: textMuted,
                                  ),
                                  _buildDivider(stripBorder),
                                  _buildNutritionCol(
                                    value: '${dish.protein}g',
                                    label: s.proteinLabel,
                                    accent: const Color(0xFF3B82F6),
                                    textDark: textDark,
                                    textMuted: textMuted,
                                  ),
                                  _buildDivider(stripBorder),
                                  _buildNutritionCol(
                                    value: '${dish.carbs}g',
                                    label: s.carbsLabel,
                                    accent: const Color(0xFF10B981),
                                    textDark: textDark,
                                    textMuted: textMuted,
                                  ),
                                  _buildDivider(stripBorder),
                                  _buildNutritionCol(
                                    value: '${dish.fat}g',
                                    label: s.fatLabel,
                                    accent: const Color(0xFFEAB308),
                                    textDark: textDark,
                                    textMuted: textMuted,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Primary CTA: Scan real meal
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: onScanMeal,
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 19,
                                ),
                                label: Text(
                                  s.guidanceScanRealMeal,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Secondary Outlined CTA: Spin Again
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton.icon(
                                onPressed: onSpinAgain,
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: textMuted,
                                ),
                                label: Text(
                                  s.spinAgainAction,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 46),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: BorderSide(color: stripBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      width: 1,
      height: 34,
      color: color,
    );
  }

  Widget _buildNutritionCol({
    required String value,
    required String label,
    required Color accent,
    required Color textDark,
    required Color textMuted,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackHeroEmoji() {
    return Container(
      color: const Color(0xFFF97316).withValues(alpha: 0.15),
      child: Center(
        child: Text(
          dish.emoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }
}

class _RemoteDishImage extends StatefulWidget {
  final String imageUrl;
  final int cacheWidth;
  final Widget Function() fallbackBuilder;

  const _RemoteDishImage({
    required this.imageUrl,
    required this.cacheWidth,
    required this.fallbackBuilder,
  });

  @override
  State<_RemoteDishImage> createState() => _RemoteDishImageState();
}

class _RemoteDishImageState extends State<_RemoteDishImage> {
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(covariant _RemoteDishImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _initImage();
    }
  }

  void _initImage() {
    final url = widget.imageUrl;
    final syncFile = WhatToEatService.instance.getCachedImageFileSync(url);
    if (syncFile != null) {
      _cachedFile = syncFile;
      return;
    }
    _cachedFile = null;
    if (url.isEmpty) return;
    unawaited(_loadFromCacheOrServer(url));
  }

  Future<void> _loadFromCacheOrServer(String url) async {
    final file = await WhatToEatService.instance.loadImageFile(url);
    if (!mounted || widget.imageUrl != url || file == null) return;
    setState(() => _cachedFile = file);
  }

  @override
  Widget build(BuildContext context) {
    final file = _cachedFile;
    if (file == null) {
      return widget.fallbackBuilder();
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      cacheWidth: widget.cacheWidth,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return widget.fallbackBuilder();
      },
      errorBuilder: (_, __, ___) => widget.fallbackBuilder(),
    );
  }
}
