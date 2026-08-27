import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/gamification.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../widgets/achievement_badge.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamificationProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final gamification = context.watch<GamificationProvider>();
    final dark = settings.isDarkMode;
    final bg = dark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final card = dark ? const Color(0xFF212027) : Colors.white;
    final text = dark ? Colors.white : const Color(0xFF0F172A);
    final muted = dark ? const Color(0xFF9A99A6) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(settings.strings.statistics,
            style: TextStyle(
                color: text, fontSize: 19, fontWeight: FontWeight.w800)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabs,
          labelColor: text,
          unselectedLabelColor: muted,
          indicatorColor: text,
          tabs: const [Tab(text: 'Dinh dưỡng'), Tab(text: 'EXP & mục tiêu')],
        ),
      ),
      body: gamification.loading && !gamification.hasStats
          ? Center(child: CircularProgressIndicator(color: text))
          : gamification.error != null && !gamification.hasStats
              ? _ErrorState(
                  onRetry: gamification.refresh, text: text, muted: muted)
              : RefreshIndicator(
                  color: text,
                  onRefresh: gamification.refresh,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _NutritionTab(
                          weekly: gamification.weekly,
                          monthly: gamification.monthly,
                          forecast: gamification.forecast,
                          card: card,
                          border: border,
                          text: text,
                          muted: muted,
                          dark: dark),
                      _ExpTab(
                          status: gamification.status,
                          achievements: gamification.achievements,
                          card: card,
                          border: border,
                          text: text,
                          muted: muted,
                          dark: dark),
                    ],
                  ),
                ),
    );
  }
}

class _NutritionTab extends StatelessWidget {
  final WeeklyStats? weekly;
  final MonthlyStats? monthly;
  final GoalForecast? forecast;
  final Color card, border, text, muted;
  final bool dark;

  const _NutritionTab(
      {required this.weekly,
      required this.monthly,
      required this.forecast,
      required this.card,
      required this.border,
      required this.text,
      required this.muted,
      required this.dark});

  @override
  Widget build(BuildContext context) {
    final week = weekly;
    final month = monthly;
    if (week == null || month == null) {
      return ListView(children: const [
        SizedBox(height: 180),
        Center(child: Text('Chưa có dữ liệu thống kê'))
      ]);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Row(children: [
          Expanded(
              child: _MetricCard(
                  label: 'Calo trung bình',
                  value: '${week.avgCalo.round()} kcal',
                  icon: Icons.local_fire_department_outlined,
                  color: const Color(0xFFF97316),
                  card: card,
                  border: border,
                  text: text,
                  muted: muted)),
          const SizedBox(width: 12),
          Expanded(
              child: _MetricCard(
                  label: 'Protein trung bình',
                  value: '${week.avgProtein.toStringAsFixed(1)} g',
                  icon: Icons.fitness_center_outlined,
                  color: const Color(0xFFFF5C5C),
                  card: card,
                  border: border,
                  text: text,
                  muted: muted)),
        ]),
        const SizedBox(height: 12),
        _SectionCard(
            card: card,
            border: border,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('7 ngày gần đây',
                  style: TextStyle(
                      color: text, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${week.daysLogged}/7 ngày có ghi nhận',
                  style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 18),
              _WeeklyBars(points: week.dailyPoints, dark: dark, muted: muted),
            ])),
        const SizedBox(height: 12),
        _SectionCard(
            card: card,
            border: border,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hoạt động 30 ngày',
                  style: TextStyle(
                      color: text, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                  '${month.loggedDays}/${month.totalDays} ngày có ghi nhận · ${month.adherencePercent.toStringAsFixed(0)}% đều đặn',
                  style: TextStyle(color: muted, fontSize: 13)),
              const SizedBox(height: 16),
              _MonthGrid(days: month.days, dark: dark),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Ít', style: TextStyle(color: muted, fontSize: 10)),
                  const SizedBox(width: 5),
                  _HeatLegend(
                      color: dark
                          ? const Color(0xFF36343F)
                          : const Color(0xFFE2E8F0)),
                  _HeatLegend(color: const Color(0xFFBBF7D0)),
                  _HeatLegend(color: const Color(0xFF4ADE80)),
                  _HeatLegend(color: const Color(0xFF15803D)),
                  const SizedBox(width: 5),
                  Text('Nhiều', style: TextStyle(color: muted, fontSize: 10)),
                ],
              ),
            ])),
        if (forecast != null) ...[
          const SizedBox(height: 12),
          _SectionCard(
              card: card,
              border: border,
              child: Row(children: [
                const Icon(Icons.track_changes_outlined,
                    color: Color(0xFF22C55E)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Dự báo mục tiêu cân nặng',
                          style: TextStyle(
                              color: text, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(forecast!.display,
                          style: TextStyle(color: muted, fontSize: 13)),
                    ])),
              ])),
        ],
      ],
    );
  }
}

class _ExpTab extends StatelessWidget {
  final GamificationStatus status;
  final List<Achievement> achievements;
  final Color card, border, text, muted;
  final bool dark;

  const _ExpTab(
      {required this.status,
      required this.achievements,
      required this.card,
      required this.border,
      required this.text,
      required this.muted,
      required this.dark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _SectionCard(
            card: card,
            border: border,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cấp ${status.level}',
                      style: TextStyle(
                          color: text,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(GamificationStatus.levelTitle(status.level),
                      style: TextStyle(color: muted, fontSize: 13)),
                ]),
                Text('${status.exp} EXP',
                    style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 16),
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                      value: status.levelProgress.clamp(0.0, 1.0),
                      minHeight: 9,
                      backgroundColor: dark
                          ? const Color(0xFF36343F)
                          : const Color(0xFFE2E8F0),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF22C55E)))),
              const SizedBox(height: 8),
              Text(
                  status.level >= 10
                      ? 'Bạn đã đạt cấp tối đa'
                      : '${(status.expToNextLevel - status.expInCurrentLevel).clamp(0, 100000)} EXP để lên cấp tiếp theo',
                  style: TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 12),
              Text(
                  'Hôm nay đã quét ${status.scansToday} món · tổng ${status.totalScans} lần',
                  style: TextStyle(color: muted, fontSize: 12)),
            ])),
        const SizedBox(height: 20),
        Text('Mốc cần đạt',
            style: TextStyle(
                color: text, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (achievements.isEmpty)
          _SectionCard(
              card: card,
              border: border,
              child: Text('Chưa có dữ liệu mốc EXP.',
                  style: TextStyle(color: muted)))
        else
          ...achievements.map((achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AchievementTile(
                  achievement: achievement,
                  card: card,
                  border: border,
                  text: text,
                  muted: muted,
                  dark: dark))),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final Color card, border, text, muted;
  final bool dark;

  const _AchievementTile(
      {required this.achievement,
      required this.card,
      required this.border,
      required this.text,
      required this.muted,
      required this.dark});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
        card: card,
        border: border,
        child: Row(children: [
          AchievementBadge(
            id: achievement.id,
            size: 48,
            opacity: achievement.unlocked ? 1 : 0.38,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(achievement.name,
                    style: TextStyle(color: text, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(achievement.description,
                    style: TextStyle(color: muted, fontSize: 12)),
                if (!achievement.unlocked &&
                    achievement.progressTarget != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                          value: achievement.progress,
                          minHeight: 6,
                          backgroundColor: dark
                              ? const Color(0xFF36343F)
                              : const Color(0xFFE2E8F0),
                          valueColor:
                              const AlwaysStoppedAnimation(Color(0xFF22C55E)))),
                  const SizedBox(height: 3),
                  Text(
                      '${achievement.progressCurrent ?? 0}/${achievement.progressTarget}',
                      style: TextStyle(color: muted, fontSize: 11)),
                ],
              ])),
          if (achievement.unlocked)
            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
        ]));
  }
}

class _WeeklyBars extends StatelessWidget {
  final List<DayCaloriePoint> points;
  final bool dark;
  final Color muted;

  const _WeeklyBars(
      {required this.points, required this.dark, required this.muted});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty)
      return Text('Chưa có dữ liệu',
          style: TextStyle(color: muted, fontSize: 13));
    final max = points.fold<double>(1,
        (value, point) => value > point.calo ? value : point.calo.toDouble());
    return SizedBox(
        height: 145,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points.map((point) {
              final label =
                  point.dateKey.length >= 10 ? point.dateKey.substring(8) : '';
              return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(point.calo == 0 ? '—' : '${point.calo}',
                        style: TextStyle(color: muted, fontSize: 9)),
                    const SizedBox(height: 5),
                    Container(
                        width: 23,
                        height: point.calo == 0
                            ? 4
                            : 92 * (point.calo / max).clamp(0.08, 1.0),
                        decoration: BoxDecoration(
                            color: point.calo == 0
                                ? (dark
                                    ? const Color(0xFF36343F)
                                    : const Color(0xFFE2E8F0))
                                : const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 7),
                    Text(label, style: TextStyle(color: muted, fontSize: 10)),
                  ]);
            }).toList()));
  }
}

class _MonthGrid extends StatelessWidget {
  final List<DayLogPoint> days;
  final bool dark;

  const _MonthGrid({required this.days, required this.dark});

  @override
  Widget build(BuildContext context) {
    final empty = dark ? const Color(0xFF36343F) : const Color(0xFFE2E8F0);
    if (days.isEmpty) {
      return Text('Chưa có dữ liệu',
          style: TextStyle(color: dark ? Colors.white70 : Colors.black54));
    }

    final firstDate = DateTime.tryParse(days.first.dateKey);
    final leading = firstDate == null ? 0 : firstDate.weekday - 1;
    final weekCount = ((leading + days.length) / 7).ceil();

    Color cellColor(int scanCount) {
      if (scanCount <= 0) return empty;
      if (scanCount == 1) return const Color(0xFFBBF7D0);
      if (scanCount == 2) return const Color(0xFF4ADE80);
      return const Color(0xFF15803D);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          height: 7 * 16 + 6 * 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('T2', style: TextStyle(fontSize: 9)),
              Text('T4', style: TextStyle(fontSize: 9)),
              Text('T6', style: TextStyle(fontSize: 9)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (weekday) {
                return Row(
                  children: List.generate(weekCount, (week) {
                    final index = week * 7 + weekday - leading;
                    final point =
                        index >= 0 && index < days.length ? days[index] : null;
                    final scanCount = point?.scanCount ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      child: Tooltip(
                        message: point == null
                            ? ''
                            : '${point.dateKey}: $scanCount lần quét',
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: point == null
                                  ? Colors.transparent
                                  : cellColor(scanCount),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, card, border, text, muted;

  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.card,
      required this.border,
      required this.text,
      required this.muted});

  @override
  Widget build(BuildContext context) => _SectionCard(
      card: card,
      border: border,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 12),
        Text(value,
            style: TextStyle(
                color: text, fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: muted, fontSize: 12))
      ]));
}

class _HeatLegend extends StatelessWidget {
  final Color color;

  const _HeatLegend({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      );
}

class _SectionCard extends StatelessWidget {
  final Color card, border;
  final Widget child;

  const _SectionCard(
      {required this.card, required this.border, required this.child});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: card,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(16)),
      child: child);
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;
  final Color text, muted;

  const _ErrorState(
      {required this.onRetry, required this.text, required this.muted});

  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Không tải được dữ liệu',
            style: TextStyle(color: text, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextButton(
            onPressed: onRetry,
            child: Text('Thử lại', style: TextStyle(color: muted)))
      ]));
}
