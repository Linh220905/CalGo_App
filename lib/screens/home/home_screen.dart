import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../services/scan_service.dart';
import '../../providers/scan_task_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/swipeable_card.dart';
import '../../widgets/mascot_speech_bubble.dart';
import '../../utils/localized_date_utils.dart';
import 'widgets/cal_ai_hero_card.dart';
import 'widgets/cal_ai_macro_card.dart';
import '../recap/daily_recap_screen.dart';
import '../../models/gamification.dart';

const _kProteinColor = Color(0xFFFF5C5C);
const _kCarbColor = Color(0xFFF59E0B);
const _kFatColor = Color(0xFF3B82F6);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _loadedUserId;
  Timer? _mascotMessageTimer;
  bool _reloadScheduled = false;
  String? _lastRecapSyncKey;

  @override
  void initState() {
    super.initState();
    _mascotMessageTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final home = context.read<HomeProvider>();
      if (home.shouldAutoRotateMascot) {
        home.cycleMascotMessage();
      }
    });
  }

  @override
  void dispose() {
    _mascotMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;

    final bgColor = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    final currentUserId = auth.user?.id ?? 'guest';
    if (!auth.loading && _loadedUserId != currentUserId && !_reloadScheduled) {
      _loadedUserId = currentUserId;
      _reloadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _reloadScheduled = false;
        if (mounted) {
          context.read<HomeProvider>().loadToday(forceRefresh: true);
          unawaited(context.read<ScanService>().preloadHistoryImages(context));
        }
      });
    }

    return Consumer<HomeProvider>(
      builder: (context, hp, _) {
        final gamification = context.watch<GamificationProvider>();
        _syncRecapFeatures(hp);
        void onMascotTap() {
          if (hp.mascotOpensMealGuidance) {
            context.push('/meal-guidance');
          } else {
            hp.cycleMascotMessage();
          }
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: hp.error != null && !hp.hasLoaded
                ? const _ErrorView()
                : RefreshIndicator(
                    color: textDark,
                    backgroundColor: cardBgColor,
                    onRefresh: () => hp.loadToday(forceRefresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top Header Bar with Mascot Speech Bubble ─────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Brand lockup with Mascot & Speech Bubble
                              Expanded(
                                child: GestureDetector(
                                  onTap: onMascotTap,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Animate(
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true),
                                        effects: const [
                                          RotateEffect(
                                            begin:
                                                -0.0349, // -2 độ (-0.0349 rad)
                                            end: 0.0349, // +2 độ (+0.0349 rad)
                                            duration:
                                                Duration(milliseconds: 1800),
                                            curve: Curves.easeInOut,
                                          ),
                                        ],
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ClipRect(
                                            child: Image.asset(
                                              hp.mascotAssetForTheme(isDark),
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              cacheWidth: 128,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                Icons.emoji_nature_rounded,
                                                size: 38,
                                                color: Color(0xFF22C55E),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: MascotSpeechBubble(
                                          message: hp.getMascotGenZMessage(s),
                                          onTap: onMascotTap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Right side buttons: Gallery + Streak
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: cardBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? const Color(0x22000000)
                                              : const Color(0x050F172A),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.photo_library_outlined,
                                          size: 18, color: textDark),
                                      onPressed: () => context.push('/gallery'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF332014)
                                          : const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF522B14)
                                              : const Color(0xFFFFEDD5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 16,
                                            color: Color(0xFFF97316)),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${hp.summary.streakDays}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? const Color(0xFFFF9D5C)
                                                : const Color(0xFFC2410C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Seven-day selector ───────────────────
                          _WeekDateSelector(
                            selectedDate: hp.selectedDate,
                            isDark: isDark,
                            onSelected: hp.selectDate,
                          ),

                          const SizedBox(height: 18),

                          // ── Main Hero Calorie Card ─────────────
                          _CalorieCardSection(),

                          const SizedBox(height: 14),

                          // ── 3 Macro Cards (Protein, Carbs, Fats) ──
                          _MacroCardsSection(),

                          const SizedBox(height: 14),

                          // ── Daily Recap Banner (Quick Access) ──────
                          if (gamification.recap != null &&
                              _isToday(hp.selectedDate) &&
                              hp.entries.isNotEmpty) ...[
                            _DailyRecapBanner(
                              recap: gamification.recap!,
                              isDark: isDark,
                              cardBg: cardBgColor,
                              border: borderColor,
                              textDark: textDark,
                              textMuted: textMuted,
                            ),
                            const SizedBox(height: 14),
                          ],

                          const SizedBox(height: 14),

                          // ── Recently Uploaded Section ──────────
                          Text(
                            s.recentlyUploaded,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (hp.loadingDiary ||
                              hp.entries.isNotEmpty ||
                              context.watch<ScanTaskProvider>().task != null)
                            const _RecentlyUploadedList(),
                        ],
                      ),
                    ),
                  ),
          ),

          // ── Floating Action Button (+) ─────────────────────────
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/scan'),
            backgroundColor: textDark,
            elevation: 6,
            shape: const CircleBorder(),
            child: Icon(Icons.add_rounded,
                color: isDark ? Colors.black : Colors.white, size: 30),
          ),
        );
      },
    );
  }

  void _syncRecapFeatures(HomeProvider hp) {
    if (!hp.hasLoaded) return;
    final now = DateTime.now();
    final dayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final selectedDayKey =
        '${hp.selectedDate.year}-${hp.selectedDate.month}-${hp.selectedDate.day}';
    final syncKey = '$dayKey:$selectedDayKey:${hp.entries.isNotEmpty}';
    if (_lastRecapSyncKey == syncKey) return;
    _lastRecapSyncKey = syncKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isToday(hp.selectedDate)) {
        unawaited(
          NotificationService.instance.scheduleDailyRecapNotification(
            hasMeals: hp.entries.isNotEmpty,
          ),
        );
      }
      unawaited(context.read<GamificationProvider>().refreshRecap());
    });
  }

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    return value.year == now.year &&
        value.month == now.month &&
        value.day == now.day;
  }
}

class _WeekDateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final bool isDark;
  final ValueChanged<DateTime> onSelected;

  const _WeekDateSelector({
    required this.selectedDate,
    required this.isDark,
    required this.onSelected,
  });

  @override
  State<_WeekDateSelector> createState() => _WeekDateSelectorState();
}

class _WeekDateSelectorState extends State<_WeekDateSelector> {
  late final ScrollController _scrollController;
  static const int _daysCount = 90; // 90 days into the past

  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dates = List.generate(
      _daysCount,
      (index) => today.subtract(Duration(days: (_daysCount - 1) - index)),
    );

    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialIndex =
          _dates.indexWhere((d) => DateUtils.isSameDay(d, widget.selectedDate));
      final targetIndex = initialIndex >= 0 ? initialIndex : _daysCount - 1;
      _scrollToIndex(targetIndex, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant _WeekDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      final index =
          _dates.indexWhere((d) => DateUtils.isSameDay(d, widget.selectedDate));
      if (index >= 0) {
        _scrollToIndex(index, animate: true);
      }
    }
  }

  void _scrollToIndex(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    const itemWidth = 52.0;
    const itemMargin = 6.0;
    const totalItemWidth = itemWidth + itemMargin;

    final screenWidth = MediaQuery.of(context).size.width - 40;
    final offset =
        (index * totalItemWidth) - (screenWidth / 2) + (itemWidth / 2);
    final clampedOffset =
        offset.clamp(0.0, _scrollController.position.maxScrollExtent);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBg = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final unselectedBg =
        widget.isDark ? const Color(0xFF212027) : const Color(0xFFF1F5F9);
    final unselectedText =
        widget.isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    final settings = context.watch<AppSettingsProvider>();
    final weekdays = localizedWeekdays(settings.languageCode);

    return SizedBox(
      height: 52,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final selected = DateUtils.isSameDay(date, widget.selectedDate);
          final weekdayIndex = date.weekday == 7 ? 0 : date.weekday;

          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: SizedBox(
              width: 52,
              child: Material(
                color: selected ? selectedBg : unselectedBg,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: selected ? null : () => widget.onSelected(date),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdays[weekdayIndex],
                          style: TextStyle(
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? (widget.isDark ? Colors.black : Colors.white)
                                : unselectedText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localizedShortDate(date, settings.languageCode),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? (widget.isDark ? Colors.black : Colors.white)
                                : (widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hero Calorie Card Section ─────────────────────────────
class _CalorieCardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HomeProvider>();
    if (!hp.hasLoaded || hp.loadingSummary) return const _CardSkeleton();

    final s = hp.summary;
    final target = s.targetCalories > 0 ? s.targetCalories : 2000;
    final remaining = s.remainingCalories;
    final pct = s.caloriesProgress;

    return CalAiHeroCard(
      caloriesConsumed: s.consumedCalories,
      caloriesLeft: remaining,
      targetCalories: target,
      progress: pct,
    );
  }
}

// ── 3 Macro Cards Section ──────────────────────────────────
class _MacroCardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HomeProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final strings = settings.strings;
    if (!hp.hasLoaded || hp.loadingSummary) return const _MacroSkeleton();

    final s = hp.summary;
    final targetProtein =
        s.targetProteinG > 0 ? s.targetProteinG.toDouble() : 120;
    final targetCarb = s.targetCarbG > 0 ? s.targetCarbG.toDouble() : 250;
    final targetFat = s.targetFatG > 0 ? s.targetFatG.toDouble() : 55;

    final proteinG = s.proteinG.toDouble();
    final carbG = s.carbG.toDouble();
    final fatG = s.fatG.toDouble();
    final proteinLeft = (targetProtein - proteinG).clamp(0.0, targetProtein);
    final carbLeft = (targetCarb - carbG).clamp(0.0, targetCarb);
    final fatLeft = (targetFat - fatG).clamp(0.0, targetFat);

    return Row(
      children: [
        // Protein
        Expanded(
          child: CalAiMacroCard(
            title: strings.gramsValue(proteinLeft.round()),
            subtitle: strings.proteinLeft,
            consumed: proteinG.round(),
            target: targetProtein.round(),
            progress: (proteinG / targetProtein).clamp(0.0, 1.0),
            color: _kProteinColor,
            trackColor: const Color(0xFFFEE2E2),
            bgIconColor: const Color(0xFFFEF2F2),
            icon: Icons.flash_on_rounded,
          ),
        ),
        const SizedBox(width: 10),
        // Carbs
        Expanded(
          child: CalAiMacroCard(
            title: strings.gramsValue(carbLeft.round()),
            subtitle: strings.carbsLeft,
            consumed: carbG.round(),
            target: targetCarb.round(),
            progress: (carbG / targetCarb).clamp(0.0, 1.0),
            color: _kCarbColor,
            trackColor: const Color(0xFFFEF3C7),
            bgIconColor: const Color(0xFFFFFBEB),
            icon: Icons.grain_rounded,
          ),
        ),
        const SizedBox(width: 10),
        // Fats
        Expanded(
          child: CalAiMacroCard(
            title: strings.gramsValue(fatLeft.round()),
            subtitle: strings.fatsLeft,
            consumed: fatG.round(),
            target: targetFat.round(),
            progress: (fatG / targetFat).clamp(0.0, 1.0),
            color: _kFatColor,
            trackColor: const Color(0xFFDBEAFE),
            bgIconColor: const Color(0xFFEFF6FF),
            icon: Icons.pie_chart_rounded,
          ),
        ),
      ],
    );
  }
}

// ── Recently Uploaded List ────────────────────────────────
class _RecentlyUploadedList extends StatelessWidget {
  const _RecentlyUploadedList();

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HomeProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final isDark = settings.isDarkMode;
    final meals = hp.entries;
    final scanTask = context.watch<ScanTaskProvider>();
    final pendingTask = scanTask.task;

    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

    if (pendingTask == null &&
        (!hp.hasLoaded || hp.loadingSummary || hp.loadingDiary)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(color: textDark, strokeWidth: 2),
        ),
      );
    }

    if (meals.isEmpty && pendingTask == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (pendingTask != null) ...[
          _PendingScanCard(task: pendingTask),
          if (meals.isNotEmpty) const SizedBox(height: 12),
        ],
        if (meals.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = meals[index];
              final timeStr = localizedTime(item.time, settings.languageCode);

              return SwipeableCard(
                confirmMessage: s.deleteMealQuestion,
                onDelete: () async {
                  try {
                    await context.read<ScanService>().deleteScan(item.id);
                    if (context.mounted) {
                      context.read<HomeProvider>().removeEntry(item.id);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.deleteMealFailed)),
                      );
                    }
                  }
                },
                child: InkWell(
                  onTap: () => context.push('/result/${item.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color(0x22000000)
                              : const Color(0x0A0F172A),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Image thumbnail
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2A34)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: item.imageUrl != null
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 136,
                                  filterQuality: FilterQuality.low,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.restaurant,
                                    size: 26,
                                    color: textMuted,
                                  ),
                                )
                              : Icon(
                                  Icons.restaurant,
                                  size: 26,
                                  color: textMuted,
                                ),
                        ),
                        const SizedBox(width: 14),

                        // Info details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Time Badge Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2C2A34)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Calorie Line: 🔥 500 kcal
                              Row(
                                children: [
                                  const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 15,
                                      color: Color(0xFFF97316)),
                                  const SizedBox(width: 4),
                                  Text(
                                    s.guidanceDishCalories(item.calories),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Macro Badges Line: ⚡ 78g   🌾 78g   💧 78g
                              Row(
                                children: [
                                  // Protein 🥩
                                  const Icon(Icons.fitness_center_rounded,
                                      size: 13, color: _kProteinColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.proteinG}g',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted),
                                  ),
                                  const SizedBox(width: 12),
                                  // Carbs 🌾
                                  const Icon(Icons.grain_rounded,
                                      size: 13, color: _kCarbColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.carbG}g',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted),
                                  ),
                                  const SizedBox(width: 12),
                                  // Fats 🥑
                                  const Icon(Icons.pie_chart_rounded,
                                      size: 13, color: _kFatColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.fatG}g',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _PendingScanCard extends StatefulWidget {
  const _PendingScanCard({required this.task});

  final ScanTask task;

  @override
  State<_PendingScanCard> createState() => _PendingScanCardState();
}

class _PendingScanCardState extends State<_PendingScanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowUnrecognizedFoodDialog();
    });
  }

  @override
  void didUpdateWidget(covariant _PendingScanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowUnrecognizedFoodDialog();
    });
  }

  void _maybeShowUnrecognizedFoodDialog() {
    if (!mounted ||
        !widget.task.isUnrecognizedFood ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    if (!widget.task.takeUnrecognizedFoodAlert()) return;
    final settings = context.read<AppSettingsProvider>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor:
            settings.isDarkMode ? const Color(0xFF212027) : Colors.white,
        title: Text(
          'Chưa nhận diện rõ món ăn',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: settings.isDarkMode ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Vui lòng chụp lại ảnh món ăn rõ ràng hơn nhé.',
          style: TextStyle(
            fontSize: 14,
            height: 1.35,
            color: settings.isDarkMode
                ? const Color(0xFFB7B5C2)
                : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) context.push('/scan');
            },
            child: const Text('Chụp lại'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final isFailed = task.status == ScanTaskStatus.failed;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final borderColor = isFailed
        ? const Color(0xFFFCA5A5)
        : isDark
            ? const Color(0xFF2C2A34)
            : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF212027) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(task.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark
                          ? const Color(0xFF2C2A34)
                          : const Color(0xFFF1F5F9),
                      child: Icon(Icons.restaurant, color: textMuted),
                    ),
                  ),
                  ColoredBox(color: Colors.black.withOpacity(0.34)),
                  Center(
                    child: isFailed
                        ? const Icon(Icons.error_outline_rounded,
                            color: Colors.white, size: 27)
                        : _ScanProgress(progress: task.progress),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: isFailed
                ? _FailedScanContent(
                    error: task.errorMessage,
                    textDark: textDark,
                    textMuted: textMuted,
                  )
                : _LoadingMealContent(
                    shimmer: _shimmerController,
                    isDark: isDark,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScanProgress extends StatelessWidget {
  const _ScanProgress({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 43,
        height: 43,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: progress / 100,
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.3),
              strokeWidth: 3,
            ),
            Center(
              child: Text(
                '$progress%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
}

class _FailedScanContent extends StatelessWidget {
  const _FailedScanContent({
    required this.error,
    required this.textDark,
    required this.textMuted,
  });

  final String? error;
  final Color textDark;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final message = switch (error) {
      'scanCreditsExhausted' => s.outOfCreditsMessage,
      'networkRetry' => s.networkRetry,
      'scanUnavailable' => s.scanUnavailable,
      'scanUnrecognizedFood' => 'Vui lòng chụp lại ảnh món ăn rõ ràng hơn nhé.',
      _ => s.scanResultRetryHint,
    };
    final title = error == 'scanUnrecognizedFood'
        ? 'Chưa nhận diện rõ món ăn'
        : s.scanResultUnavailable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 6),
        Text(message, style: TextStyle(fontSize: 12.5, color: textMuted)),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: () => context.read<ScanTaskProvider>().retry(),
          child: Text(s.retry,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}

class _LoadingMealContent extends StatelessWidget {
  const _LoadingMealContent({required this.shimmer, required this.isDark});

  final Animation<double> shimmer;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBar(
              width: 118, height: 15, value: shimmer.value, isDark: isDark),
          const SizedBox(height: 10),
          _ShimmerBar(
              width: 66, height: 12, value: shimmer.value, isDark: isDark),
          const SizedBox(height: 10),
          _ShimmerBar(
              width: 78, height: 14, value: shimmer.value, isDark: isDark),
          const SizedBox(height: 10),
          Row(
            children: [
              _ShimmerBar(
                  width: 30, height: 12, value: shimmer.value, isDark: isDark),
              const SizedBox(width: 14),
              _ShimmerBar(
                  width: 30, height: 12, value: shimmer.value, isDark: isDark),
              const SizedBox(width: 14),
              _ShimmerBar(
                  width: 30, height: 12, value: shimmer.value, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.width,
    required this.height,
    required this.value,
    required this.isDark,
  });

  final double width;
  final double height;
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF34333C) : const Color(0xFFF0F1F3);
    final glow = isDark ? const Color(0xFF50505C) : const Color(0xFFFFFFFF);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height),
        gradient: LinearGradient(
          begin: Alignment(-2 + value * 4, 0),
          end: Alignment(-1 + value * 4, 0),
          colors: [base, glow, base],
          stops: const [0.2, 0.5, 0.8],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppSettingsProvider>().isDarkMode;
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF212027) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _MacroSkeleton extends StatelessWidget {
  const _MacroSkeleton();
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppSettingsProvider>().isDarkMode;
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF212027) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Color(0xFF64748B)),
              const SizedBox(height: 16),
              Text(context.watch<AppSettingsProvider>().strings.dataLoadFailed,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}

class _DailyRecapBanner extends StatelessWidget {
  final DailyRecap recap;
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _DailyRecapBanner({
    required this.recap,
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x0A0F172A),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showDailyRecap(
              context,
              recap: recap,
              onFinish: () {
                unawaited(context.read<GamificationProvider>().finishRecap());
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFF22C55E), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng kết ngày & AI Coach',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Xem đánh giá dinh dưỡng & nhận EXP',
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
