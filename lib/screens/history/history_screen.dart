import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_build_config.dart';
import '../../models/history_item.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/scan_service.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/localized_date_utils.dart';
import 'widgets/month_calendar_grid.dart';
import 'widgets/day_detail_bottom_sheet.dart';

import '../../utils/macro_icons.dart';

String _formatYMD(DateTime dt) {
  return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _items = [];
  bool _loading = true;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({bool forceRefresh = false}) async {
    try {
      final service = context.read<ScanService>();
      final data = await service.getAllHistory(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _items = data;
          _loading = false;
        });
        service.precacheItems(context, data.take(12).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _deleteItem(String id) async {
    final strings = context.read<AppSettingsProvider>().strings;
    try {
      await context.read<ScanService>().deleteScan(id);
      if (mounted) {
        setState(() {
          _items.removeWhere((i) => i.id == id);
        });
      }
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.cannotDeleteMeal)));
      }
      return false;
    }
  }

  int _calculateStreak() {
    final dates = _items
        .map((i) => parseApiDateTime(i.createdAt))
        .whereType<DateTime>()
        .map(_formatYMD)
        .toSet();
    var d = DateTime.now();
    if (!dates.contains(_formatYMD(d))) {
      d = d.subtract(const Duration(days: 1));
    }
    if (!dates.contains(_formatYMD(d))) return 0;
    int count = 0;
    while (true) {
      final key = _formatYMD(d);
      if (!dates.contains(key)) break;
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<AppSettingsProvider>();
    final strings = settings.strings;

    final bgColor = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final cardColor = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF34313D) : const Color(0xFFEDEDEB);
    final subtitleColor = isDark
        ? const Color(0xFFA7A5B0)
        : const Color(0xFF747780);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF111318);
    const accentColor = Color(0xFF63A97B);

    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: accentColor,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '...',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: subtitleColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final streak = _calculateStreak();
    final totalMeals = _items.length;
    final totalDays = _items
        .map(
          (i) => i.createdAt.length >= 10 ? i.createdAt.substring(0, 10) : '',
        )
        .where((s) => s.isNotEmpty)
        .toSet()
        .length;

    double sumCalo = 0;
    double sumProtein = 0;
    for (final i in _items) {
      sumCalo += i.totalCalo;
      sumProtein += i.totalProtein;
    }
    final avgCalo = totalDays > 0 ? (sumCalo / totalDays).round() : 0;
    final avgProtein = totalDays > 0 ? (sumProtein / totalDays).round() : 0;

    // Group into months
    final monthsMap = <String, Map<int, List<HistoryItem>>>{};
    for (final item in _items) {
      final dt = DateTime.tryParse(item.createdAt);
      if (dt == null) continue;
      final mKey = '${dt.year}-${dt.month}';
      monthsMap.putIfAbsent(mKey, () => {});
      monthsMap[mKey]!.putIfAbsent(dt.day, () => []).add(item);
    }
    final sortedMonthKeys = monthsMap.keys.toList()
      ..sort((a, b) {
        final ap = a.split('-');
        final bp = b.split('-');
        final av = int.parse(ap[0]) * 100 + int.parse(ap[1]);
        final bv = int.parse(bp[0]) * 100 + int.parse(bp[1]);
        return bv.compareTo(av);
      });

    final todayKey = _formatYMD(DateTime.now());
    final user = context.watch<AuthProvider>().user;
    if (user != null && _loadedUserId != user.id) {
      _loadedUserId = user.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadHistory(forceRefresh: true);
      });
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor: cardColor,
          onRefresh: () => _loadHistory(forceRefresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Modern Editorial Header ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.historyTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.beVietnamPro(
                                color: primaryTextColor,
                                fontSize: 24,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              strings.mealCount(totalMeals),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.beVietnamPro(
                                color: subtitleColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _AvatarButton(
                        user: user,
                        isDark: isDark,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Stats Card (Option 2: Hero Streak + Metrics) ──
              if (_items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _StatsGrid(
                      totalMeals: totalMeals,
                      streak: streak,
                      avgCalo: avgCalo,
                      avgProtein: avgProtein,
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      subtitleColor: subtitleColor,
                      primaryTextColor: primaryTextColor,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // ── Empty State ─────────────────────────────
              if (_items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: _EmptyState(
                      isDark: isDark,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      subtitleColor: subtitleColor,
                      primaryTextColor: primaryTextColor,
                      onScan: () => context.push('/scan'),
                    ),
                  ),
                ),

              // ── Monthly Calendar Grids ──────────────────
              if (_items.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final mKey = sortedMonthKeys[i];
                    final parts = mKey.split('-');
                    final year = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final label =
                        '${localizedMonth(DateTime(year, month), settings.languageCode)} $year';
                    final dayMap = monthsMap[mKey]!;

                    int monthTotal = 0;
                    final daysList = <DayGroupData>[];
                    dayMap.forEach((dayNum, items) {
                      monthTotal += items.length;
                      final fDate = _formatYMD(DateTime(year, month, dayNum));
                      daysList.add(
                        DayGroupData(
                          date: dayNum,
                          fullDate: fDate,
                          items: items,
                          isToday: fDate == todayKey,
                        ),
                      );
                    });

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MonthCalendarGrid(
                        monthLabel: label,
                        totalMeals: monthTotal,
                        year: year,
                        month: month,
                        days: daysList,
                        isDark: isDark,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        subtitleColor: subtitleColor,
                        primaryTextColor: primaryTextColor,
                        onSelectDay: (dayData) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => DayDetailBottomSheet(
                              dateLabel: dayData.fullDate,
                              items: dayData.items,
                              onDeleteMeal: (id) async {
                                final deleted = await _deleteItem(id);
                                if (deleted && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          );
                        },
                        onSelectTodayEmpty: () => context.push('/scan'),
                      ),
                    );
                  }, childCount: sortedMonthKeys.length),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats Grid Widget (Hero Streak + Compact Metrics) ──────────────────────────

class _StatsGrid extends StatelessWidget {
  final int totalMeals;
  final int streak;
  final int avgCalo;
  final int avgProtein;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color primaryTextColor;

  const _StatsGrid({
    required this.totalMeals,
    required this.streak,
    required this.avgCalo,
    required this.avgProtein,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    const fireColor = Color(0xFFF97316);
    final fireBg = isDark ? const Color(0xFF332014) : const Color(0xFFFFF7ED);
    const fireBorder = Color(0x33F97316);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          // ── Streak Hero Block ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: fireBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fireBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: fireColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: fireColor,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.streakDaysLabel,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: fireColor,
                        height: 1.1,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ── Metric Rows (Calo & Protein) ──
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          strings.kcalPerDay,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$avgCalo kcal',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MacroIcons.protein(size: 14),
                        const SizedBox(width: 4),
                        Text(
                          strings.proteinPerDay,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${avgProtein}g',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFF5C5C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Button ────────────────────────────────────────────────────────────

class _AvatarButton extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _AvatarButton({
    required this.user,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: user?.avatar != null
                ? Image.network(user!.avatar!, fit: BoxFit.cover)
                : Text(
                    user?.name?.isNotEmpty == true
                        ? user!.name![0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.beVietnamPro(
                      color: isDark ? Colors.white : const Color(0xFF111318),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
          if (!AppBuildConfig.isTesting && user?.hasPremiumAccess == true)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color primaryTextColor;
  final VoidCallback onScan;

  const _EmptyState({
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.primaryTextColor,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    const accentColor = Color(0xFF63A97B);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF24352A)
                    : const Color(0xFFE2F1E7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                size: 26,
                color: accentColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          strings.noMealsHistory,
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.scanFirstMealPrompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: subtitleColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onScan,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                strings.scanFirstMealButton,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
