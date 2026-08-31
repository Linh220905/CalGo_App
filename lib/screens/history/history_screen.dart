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

    final bgColor = isDark ? const Color(0xFF0E0E10) : const Color(0xFFF7F7F8);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final subtitleColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFF8E8E93);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

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
                  color: const Color(0xFFFF9F0A),
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
          color: const Color(0xFFFF9F0A),
          backgroundColor: cardColor,
          onRefresh: () => _loadHistory(forceRefresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── SliverAppBar-style header ───────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              strings.historySubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 13,
                                color: subtitleColor,
                                fontWeight: FontWeight.w400,
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
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Stats Grid ─────────────────────────────
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
                      subtitleColor: subtitleColor,
                      primaryTextColor: primaryTextColor,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Empty State ─────────────────────────────
              if (_items.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: _EmptyState(
                      isDark: isDark,
                      cardColor: cardColor,
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

// ── Stats Grid Widget ────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int totalMeals;
  final int streak;
  final int avgCalo;
  final int avgProtein;
  final bool isDark;
  final Color cardColor;
  final Color subtitleColor;
  final Color primaryTextColor;

  const _StatsGrid({
    required this.totalMeals,
    required this.streak,
    required this.avgCalo,
    required this.avgProtein,
    required this.isDark,
    required this.cardColor,
    required this.subtitleColor,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isNarrow ? 1.25 : 1.6,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            children: [
              _StatCell(
                value: '$totalMeals',
                label: strings.mealsCountLabel,
                icon: _MealIcon(isDark: isDark),
                accentColor: const Color(0xFFFF9F0A),
                isDark: isDark,
                cardColor: cardColor,
                subtitleColor: subtitleColor,
                primaryTextColor: primaryTextColor,
                isTopLeft: true,
              ),
              _StatCell(
                value: '$streak',
                label: strings.streakDaysLabel,
                icon: _FireIcon(isDark: isDark),
                accentColor: const Color(0xFFFF6B35),
                isDark: isDark,
                cardColor: cardColor,
                subtitleColor: subtitleColor,
                primaryTextColor: primaryTextColor,
                isTopRight: true,
              ),
              _StatCell(
                value: '$avgCalo',
                label: strings.kcalPerDay,
                icon: _CalIcon(isDark: isDark),
                accentColor: const Color(0xFF0A84FF),
                isDark: isDark,
                cardColor: cardColor,
                subtitleColor: subtitleColor,
                primaryTextColor: primaryTextColor,
                isBottomLeft: true,
              ),
              _StatCell(
                value: '${avgProtein}g',
                label: strings.proteinPerDay,
                icon: _ProteinIcon(isDark: isDark),
                accentColor: const Color(0xFF30D158),
                isDark: isDark,
                cardColor: cardColor,
                subtitleColor: subtitleColor,
                primaryTextColor: primaryTextColor,
                isBottomRight: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Widget icon;
  final Color accentColor;
  final bool isDark;
  final Color cardColor;
  final Color subtitleColor;
  final Color primaryTextColor;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.cardColor,
    required this.subtitleColor,
    required this.primaryTextColor,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    final radius = BorderRadius.only(
      topLeft: isTopLeft ? const Radius.circular(19) : Radius.zero,
      topRight: isTopRight ? const Radius.circular(19) : Radius.zero,
      bottomLeft: isBottomLeft ? const Radius.circular(19) : Radius.zero,
      bottomRight: isBottomRight ? const Radius.circular(19) : Radius.zero,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 150;
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: radius,
            border: Border(
              right: (isTopLeft || isBottomLeft)
                  ? BorderSide(color: dividerColor, width: 0.5)
                  : BorderSide.none,
              bottom: (isTopLeft || isTopRight)
                  ? BorderSide(color: dividerColor, width: 0.5)
                  : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 18,
            vertical: isCompact ? 12 : 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Custom Icon Widgets ──────────────────────────────────────────────────────

class _MealIcon extends StatelessWidget {
  final bool isDark;
  const _MealIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFFF9F0A).withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.fork_right_rounded,
        color: Color(0xFFFF9F0A),
        size: 20,
      ),
    );
  }
}

class _FireIcon extends StatelessWidget {
  final bool isDark;
  const _FireIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.local_fire_department_rounded,
        color: Color(0xFFFF6B35),
        size: 20,
      ),
    );
  }
}

class _CalIcon extends StatelessWidget {
  final bool isDark;
  const _CalIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF0A84FF).withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(Icons.bolt_rounded, color: Color(0xFF0A84FF), size: 20),
    );
  }
}

class _ProteinIcon extends StatelessWidget {
  final bool isDark;
  const _ProteinIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF30D158).withOpacity(isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.egg_alt_rounded,
        color: Color(0xFF30D158),
        size: 20,
      ),
    );
  }
}

// ── Avatar Button ────────────────────────────────────────────────────────────

class _AvatarButton extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  final Color cardColor;

  const _AvatarButton({
    required this.user,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardColor,
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.08),
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
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
          if (!AppBuildConfig.isTesting && user?.hasPremiumAccess == true)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  size: 10,
                  color: Color(0xFF7A5C00),
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
  final VoidCallback onScan;

  const _EmptyState({
    required this.isDark,
    required this.cardColor,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    final subtitleColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFF8E8E93);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.restaurant_outlined,
            size: 30,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.noMealsHistory,
          style: GoogleFonts.beVietnamPro(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.scanFirstMealPrompt,
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: subtitleColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: onScan,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F0A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.scanFirstMealButton,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
