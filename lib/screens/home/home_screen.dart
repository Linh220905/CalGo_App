import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/scan_service.dart';
import '../../widgets/swipeable_card.dart';
import 'widgets/cal_ai_hero_card.dart';
import 'widgets/cal_ai_macro_card.dart';

const _kProteinColor = Color(0xFFFF5C5C);
const _kCarbColor = Color(0xFFF59E0B);
const _kFatColor = Color(0xFF3B82F6);

String _formatTime(DateTime? dt) {
  if (dt == null) return '9:00am';
  final hourNum = dt.hour;
  final minuteNum = dt.minute;
  final isPm = hourNum >= 12;
  final h = hourNum % 12 == 0 ? 12 : hourNum % 12;
  final m = minuteNum.toString().padLeft(2, '0');
  final ampm = isPm ? 'pm' : 'am';
  return '$h:$m$ampm';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _loadedUserId;

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

    final userId = auth.user?.id;
    if (!auth.loading && userId != null && _loadedUserId != userId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HomeProvider>().loadToday(forceRefresh: true);
        }
      });
    } else if (!auth.loading && userId == null) {
      _loadedUserId = null;
    }

    return Consumer<HomeProvider>(
      builder: (context, hp, _) => Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: hp.error != null && !hp.hasLoaded
              ? _ErrorView(hp.error!)
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
                        // ── Top Header Bar ─────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Brand lockup: crop the transparent vertical padding
                            // inside the portrait mascot asset so it reads at full size.
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                  effects: const [
                                    RotateEffect(
                                      begin: -0.0349, // -2 độ (-0.0349 rad)
                                      end: 0.0349, // +2 độ (+0.0349 rad)
                                      duration: Duration(milliseconds: 1800),
                                      curve: Curves.easeInOut,
                                    ),
                                  ],
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: ClipRect(
                                      child: Image.asset(
                                        'assets/images/apple_mascot/apple_hello.png',
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                        cacheWidth: 128,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                          Icons.emoji_nature_rounded,
                                          size: 48,
                                          color: Color(0xFF22C55E),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'CalGo',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                    letterSpacing: -0.8,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),

                            // Right side buttons: Reset Onboard + Gallery + Streak
                            Row(
                              children: [
                                // Nút Reset Onboard (38x38 compact icon button để tránh tràn màn hình)
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF3F1D24)
                                        : const Color(0xFFFFE4E6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF701A28)
                                          : const Color(0xFFFECDD3),
                                    ),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.restart_alt_rounded,
                                        size: 20, color: Color(0xFFE11D48)),
                                    tooltip: 'Reset Onboard UI',
                                    onPressed: () async {
                                      await context
                                          .read<OnboardingProvider>()
                                          .resetOnboarding();
                                      if (context.mounted) {
                                        context.go('/onboarding');
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 38,
                                  height: 38,
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
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
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
                                          size: 18,
                                          color: Color(0xFFF97316)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hp.summary.streakDays}',
                                        style: TextStyle(
                                          fontSize: 14,
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

                        const SizedBox(height: 28),

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

                        if (hp.loadingDiary || hp.entries.isNotEmpty)
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
      ),
    );
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
  static const _weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
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
    final offset = (index * totalItemWidth) - (screenWidth / 2) + (itemWidth / 2);
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
                          _weekdayLabels[date.weekday - 1],
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
                          '${date.day}/${date.month}',
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

    return Row(
      children: [
        // Protein
        Expanded(
          child: CalAiMacroCard(
            title: '${proteinG.round()}g',
            subtitle: strings.proteinLeft,
            progress: (proteinG / targetProtein).clamp(0.0, 1.0),
            color: _kProteinColor,
            trackColor: const Color(0xFFFEE2E2),
            bgIconColor: const Color(0xFFFEF2F2),
            icon: Icons.flash_on_rounded, // ⚡ Tia sét
          ),
        ),
        const SizedBox(width: 10),
        // Carbs
        Expanded(
          child: CalAiMacroCard(
            title: '${carbG.round()}g',
            subtitle: strings.carbsLeft,
            progress: (carbG / targetCarb).clamp(0.0, 1.0),
            color: _kCarbColor,
            trackColor: const Color(0xFFFEF3C7),
            bgIconColor: const Color(0xFFFFFBEB),
            icon: Icons.grain_rounded, // 🌾 Lúa mạch
          ),
        ),
        const SizedBox(width: 10),
        // Fats
        Expanded(
          child: CalAiMacroCard(
            title: '${fatG.round()}g',
            subtitle: strings.fatsLeft,
            progress: (fatG / targetFat).clamp(0.0, 1.0),
            color: _kFatColor,
            trackColor: const Color(0xFFDBEAFE),
            bgIconColor: const Color(0xFFEFF6FF),
            icon: Icons.pie_chart_rounded, // 🥑 Chất béo
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
    final isDark = settings.isDarkMode;
    final meals = hp.entries;

    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

    if (!hp.hasLoaded || hp.loadingSummary || hp.loadingDiary) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(color: textDark, strokeWidth: 2),
        ),
      );
    }

    if (meals.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = meals[index];
        final timeStr = _formatTime(item.time);

        return SwipeableCard(
          confirmMessage: 'Bạn có muốn xóa bữa ăn này không?',
          onDelete: () async {
            try {
              await context.read<ScanService>().deleteScan(item.id);
              if (context.mounted) {
                context.read<HomeProvider>().removeEntry(item.id);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Không thể xóa món ăn. Vui lòng thử lại.')),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            const Icon(Icons.local_fire_department_rounded,
                                size: 15, color: Color(0xFFF97316)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.calories} kcal',
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
  final String msg;
  const _ErrorView(this.msg);
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Color(0xFF64748B)),
              const SizedBox(height: 16),
              Text(msg,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
}
