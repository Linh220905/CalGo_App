import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/gamification.dart';
import '../../models/progress.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/achievement_badge.dart';
import '../../utils/macro_colors.dart';
import '../recap/daily_recap_screen.dart';

const _kAccent = Color(0xFF63A97B);
const _kAccentSoft = Color(0xFFE2F1E7);
const _kProtein = MacroColors.protein;
const _kCarbs = MacroColors.carb;
const _kFat = MacroColors.fat;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAll());
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      context.read<GamificationProvider>().refresh(),
      context.read<ProgressProvider>().refresh(),
    ]);
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
    final progress = context.watch<ProgressProvider>();
    final dark = settings.isDarkMode;
    final bg = dark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final card = dark ? const Color(0xFF212027) : Colors.white;
    final text = dark ? Colors.white : const Color(0xFF111318);
    final muted = dark ? const Color(0xFFA7A5B0) : const Color(0xFF747780);
    final border = dark ? const Color(0xFF34313D) : const Color(0xFFECECE9);
    final strings = settings.strings;
    final loading =
        gamification.loading &&
        !gamification.hasStats &&
        progress.loading &&
        progress.data == null;
    final hasAnyData = gamification.hasStats || progress.data != null;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.analysisEyebrow.toUpperCase(),
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.progressTitle,
                    style: TextStyle(
                      color: text,
                      fontSize: 36,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.1,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _StatsTabBar(
                    controller: _tabs,
                    card: card,
                    text: text,
                    muted: muted,
                    border: border,
                    progressLabel: strings.progressLabel,
                    statsLabel: strings.statistics,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _kAccent),
                    )
                  : !hasAnyData &&
                        (gamification.error != null || progress.error != null)
                  ? _ErrorState(onRetry: _refreshAll, text: text, muted: muted)
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _ProgressTab(
                          progress: progress,
                          weekly: gamification.weekly,
                          monthly: gamification.monthly,
                          forecast: gamification.forecast,
                          card: card,
                          border: border,
                          text: text,
                          muted: muted,
                          dark: dark,
                          onRefresh: _refreshAll,
                        ),
                        _ExpTab(
                          status: gamification.status,
                          achievements: gamification.achievements,
                          card: card,
                          border: border,
                          text: text,
                          muted: muted,
                          dark: dark,
                          onRefresh: _refreshAll,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTabBar extends StatelessWidget {
  final TabController controller;
  final Color card, text, muted, border;
  final String progressLabel, statsLabel;

  const _StatsTabBar({
    required this.controller,
    required this.card,
    required this.text,
    required this.muted,
    required this.border,
    required this.progressLabel,
    required this.statsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: _kAccentSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: text,
        unselectedLabelColor: muted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: progressLabel),
          Tab(text: statsLabel),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatefulWidget {
  final ProgressProvider progress;
  final WeeklyStats? weekly;
  final MonthlyStats? monthly;
  final GoalForecast? forecast;
  final Color card, border, text, muted;
  final bool dark;
  final Future<void> Function() onRefresh;

  const _ProgressTab({
    required this.progress,
    required this.weekly,
    required this.monthly,
    required this.forecast,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
    required this.onRefresh,
  });

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  int _weightRangeDays = 90;

  Future<void> _selectWeightRange(int days) async {
    if (_weightRangeDays == days || widget.progress.loading) return;
    setState(() => _weightRangeDays = days);
    await widget.progress.refresh(days: days);
  }

  Future<void> _showWeightDialog() async {
    final current = widget.progress.data?.currentWeightKg ?? 70.0;
    final lastWeight = widget.progress.data?.currentWeightKg;
    final result = await showModalBottomSheet<_LogWeightResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LogWeightModalSheet(
        initialWeight: current,
        lastWeight: lastWeight,
        isDark: widget.dark,
      ),
    );

    if (result == null || !mounted) return;

    final saved = await widget.progress.logWeight(
      result.weightKg,
      date: result.date,
      photoPath: result.photoPath,
    );
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Đã cập nhật cân nặng thành công'
          : 'Không thể lưu cân nặng. Vui lòng thử lại.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.progress.data;
    return RefreshIndicator(
      color: _kAccent,
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: [
          _WeightHeroCard(
            data: data,
            card: widget.card,
            border: widget.border,
            text: widget.text,
            muted: widget.muted,
            dark: widget.dark,
            onLogWeight: _showWeightDialog,
          ),
          const SizedBox(height: 16),
          _WeightProgressCard(
            data: data,
            card: widget.card,
            border: widget.border,
            text: widget.text,
            muted: widget.muted,
            dark: widget.dark,
            rangeDays: _weightRangeDays,
            loading: widget.progress.loading,
            onRangeChanged: _selectWeightRange,
          ),
          const SizedBox(height: 16),
          _WeightChangeCard(
            changes: data?.weightChanges ?? const [],
            card: widget.card,
            border: widget.border,
            text: widget.text,
            muted: widget.muted,
            dark: widget.dark,
            onLogWeight: _showWeightDialog,
          ),
          if (widget.weekly != null) ...[
            const SizedBox(height: 24),
            _SectionLabel('DINH DƯỠNG', widget.muted),
            const SizedBox(height: 9),
            _NutritionSummaryCard(
              weekly: widget.weekly!,
              card: widget.card,
              border: widget.border,
              text: widget.text,
              muted: widget.muted,
              dark: widget.dark,
            ),
            const SizedBox(height: 12),
            TargetTimelineCard(
              todayCalories: widget.weekly!.dailyPoints.isNotEmpty
                  ? widget.weekly!.dailyPoints.last.calo.toDouble()
                  : widget.weekly!.avgCalo,
              calorieTarget: widget.weekly!.dailyPoints.isNotEmpty &&
                      widget.weekly!.dailyPoints.last.target > 0
                  ? widget.weekly!.dailyPoints.last.target.toDouble()
                  : null,
              isDark: widget.dark,
              cardBg: widget.card,
              border: widget.border,
              textDark: widget.text,
              textMuted: widget.muted,
            ),
          ],
          if (widget.monthly != null) ...[
            const SizedBox(height: 12),
            _ActivityCard(
              monthly: widget.monthly!,
              card: widget.card,
              border: widget.border,
              text: widget.text,
              muted: widget.muted,
              dark: widget.dark,
            ),
          ],
          if (data?.bmi != null) ...[
            const SizedBox(height: 24),
            _SectionLabel('SỨC KHỎE', widget.muted),
            const SizedBox(height: 9),
            _BmiCard(
              data: data!,
              card: widget.card,
              border: widget.border,
              text: widget.text,
              muted: widget.muted,
            ),
          ],
          if (widget.forecast != null) ...[
            const SizedBox(height: 12),
            _ForecastCard(
              forecast: widget.forecast!,
              card: widget.card,
              border: widget.border,
              text: widget.text,
              muted: widget.muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightHeroCard extends StatelessWidget {
  final ProgressStats? data;
  final Color card, border, text, muted;
  final bool dark;
  final VoidCallback onLogWeight;

  const _WeightHeroCard({
    required this.data,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
    required this.onLogWeight,
  });

  @override
  Widget build(BuildContext context) {
    final current = data?.currentWeightKg;
    final start = data?.startWeightKg;
    final target = data?.targetWeightKg;
    final hasProgress = current != null && start != null && target != null;
    double covered = 0.0;
    if (current != null && start != null && target != null) {
      final currentValue = current;
      final startValue = start;
      final targetValue = target;
      if ((startValue - targetValue).abs() > 0.01) {
        covered = ((startValue - currentValue) / (startValue - targetValue))
            .clamp(0.0, 1.0);
      }
    }

    return _Card(
      card: card,
      border: border,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Kicker('CÂN NẶNG HIỆN TẠI', muted),
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        current == null ? '--' : current.toStringAsFixed(1),
                        style: TextStyle(
                          color: text,
                          fontSize: 48,
                          height: .95,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text('kg', style: TextStyle(color: muted, fontSize: 18)),
                    ],
                  ),
                  if (current != null && start != null && (current - start).abs() >= 0.1) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          (current - start) <= 0
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          size: 15,
                          color: (current - start) <= 0
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(current - start).abs().toStringAsFixed(1)} kg từ Aug ${DateTime.now().year}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: (current - start) <= 0
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              ElevatedButton.icon(
                onPressed: onLogWeight,
                icon: const Text(
                  'Ghi cân nặng',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                label: const Icon(Icons.arrow_forward_rounded, size: 16),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                  foregroundColor: dark
                      ? const Color(0xFF0F172A)
                      : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double trackWidth = constraints.maxWidth;
              final double dotX = (trackWidth * covered).clamp(
                6.0,
                trackWidth - 6.0,
              );
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    width: trackWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF34313D)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (hasProgress) ...[
                    Container(
                      width: dotX,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Positioned(
                      left: dotX - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF95A49),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x38F95A49),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BẮT ĐẦU',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    start == null ? '--' : '${start.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MỤC TIÊU',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    target == null ? '--' : '${target.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightProgressCard extends StatelessWidget {
  final ProgressStats? data;
  final Color card, border, text, muted;
  final bool dark, loading;
  final int rangeDays;
  final ValueChanged<int> onRangeChanged;

  const _WeightProgressCard({
    required this.data,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
    required this.loading,
    required this.rangeDays,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final points = data?.weightHistory ?? const <WeightPoint>[];
    final percent = data?.progressPercent;

    return _Card(
      card: card,
      border: border,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tiến trình cân nặng',
                  style: TextStyle(
                    color: text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (percent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.outlined_flag_rounded,
                        size: 15,
                        color: Color(0xFFD9381E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${percent.toStringAsFixed(0)}% của mục tiêu',
                        style: const TextStyle(
                          color: Color(0xFFD9381E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (loading)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (points.isEmpty)
            _EmptyChart(
              message: 'Chưa có đủ dữ liệu cân nặng',
              muted: muted,
              height: 150,
            )
          else
            _WeightChart(points: points, muted: muted, dark: dark),
          const SizedBox(height: 16),
          _RangeSelector(
            value: rangeDays,
            dark: dark,
            onChanged: onRangeChanged,
          ),
        ],
      ),
    );
  }
}

class _NutritionSummaryCard extends StatefulWidget {
  final WeeklyStats weekly;
  final Color card, border, text, muted;
  final bool dark;

  const _NutritionSummaryCard({
    required this.weekly,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
  });

  @override
  State<_NutritionSummaryCard> createState() => _NutritionSummaryCardState();
}

class _NutritionSummaryCardState extends State<_NutritionSummaryCard> {
  int _selectedWeekIndex = 0; // 0: Tuần này, 1: Tuần trước, 2: 2 tuần trước, 3: 3 tuần trước

  String _formatCalo(double value) {
    final valInt = value.round();
    final str = valInt.toString();
    return str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final caloStr = _formatCalo(widget.weekly.avgCalo);
    final target = widget.weekly.dailyPoints.isEmpty
        ? 0
        : widget.weekly.dailyPoints
            .map((point) => point.target)
            .reduce((a, b) => a > b ? a : b);
    final balance = target > 0 ? widget.weekly.avgCalo - target : 0;
    final targetColor =
        widget.dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return _Card(
      card: widget.card,
      border: widget.border,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Thống kê Calo & Dinh dưỡng',
            style: TextStyle(
              color: widget.text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),

          // Energy Metrics Row (ĐÃ NẠP | MỤC TIÊU | CHÊNH LỆCH)
          Row(
            children: [
              Expanded(
                child: _EnergyMetric(
                  label: 'ĐÃ NẠP (TB)',
                  value: caloStr.isEmpty ? '0' : caloStr,
                  color: widget.text,
                  muted: widget.muted,
                ),
              ),
              Expanded(
                child: _EnergyMetric(
                  label: 'MỤC TIÊU',
                  value: target == 0 ? '--' : _formatCalo(target.toDouble()),
                  color: widget.text,
                  muted: widget.muted,
                ),
              ),
              Expanded(
                child: _EnergyMetric(
                  label: 'CHÊNH LỆCH',
                  value: target == 0
                      ? '--'
                      : '${balance >= 0 ? '+' : ''}${balance.round()}',
                  color: balance > 0 ? _kAccent : const Color(0xFF36A269),
                  muted: widget.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Unified Dual-Bar Chart per day (Col 1: Target | Col 2: Stacked Macros)
          _UnifiedNutritionChart(
            points: widget.weekly.dailyPoints,
            muted: widget.muted,
            dark: widget.dark,
          ),
          const SizedBox(height: 16),

          // Legend dots: • Mục tiêu  • Đạm  • Carb  • Béo
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              _LegendDot(
                color: targetColor,
                label: 'Mục tiêu',
                muted: widget.muted,
              ),
              _LegendDot(
                color: MacroColors.protein,
                label: 'Đạm',
                muted: widget.muted,
              ),
              _LegendDot(
                color: MacroColors.carb,
                label: 'Carb',
                muted: widget.muted,
              ),
              _LegendDot(
                color: MacroColors.fat,
                label: 'Béo',
                muted: widget.muted,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Horizontal Week Filter Pills Container
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.dark
                  ? const Color(0xFF2B2934)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildWeekPill('Tuần này', 0),
                  _buildWeekPill('Tuần trước', 1),
                  _buildWeekPill('2 tuần trước', 2),
                  _buildWeekPill('3 tuần trước', 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekPill(String label, int index) {
    final isSelected = _selectedWeekIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedWeekIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.dark ? const Color(0xFF383644) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? widget.text
                : (widget.dark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  final WeeklyStats weekly;
  final Color card, border, text, muted;
  final bool dark;

  const _EnergyCard({
    required this.weekly,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final target = weekly.dailyPoints.isEmpty
        ? 0
        : weekly.dailyPoints
              .map((point) => point.target)
              .reduce((a, b) => a > b ? a : b);
    final balance = target > 0 ? weekly.avgCalo - target : 0;
    return _Card(
      card: card,
      border: border,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Năng lượng hàng tuần',
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EnergyMetric(
                  label: 'ĐÃ NẠP',
                  value: '${weekly.avgCalo.round()}',
                  color: text,
                  muted: muted,
                ),
              ),
              Expanded(
                child: _EnergyMetric(
                  label: 'MỤC TIÊU',
                  value: target == 0 ? '--' : '$target',
                  color: text,
                  muted: muted,
                ),
              ),
              Expanded(
                child: _EnergyMetric(
                  label: 'CHÊNH LỆCH',
                  value: target == 0
                      ? '--'
                      : '${balance >= 0 ? '+' : ''}${balance.round()}',
                  color: balance > 0 ? _kAccent : const Color(0xFF36A269),
                  muted: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _EnergyBars(points: weekly.dailyPoints, muted: muted, dark: dark),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: _kAccent, label: 'Đã nạp', muted: muted),
              const SizedBox(width: 18),
              _LegendDot(
                color: dark ? Colors.white70 : const Color(0xFF111318),
                label: 'Mục tiêu',
                muted: muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final MonthlyStats monthly;
  final Color card, border, text, muted;
  final bool dark;

  const _ActivityCard({
    required this.monthly,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) => _Card(
    card: card,
    border: border,
    radius: 26,
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hoạt động ghi nhận',
                style: TextStyle(
                  color: text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${monthly.adherencePercent.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: _kAccent,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${monthly.loggedDays}/${monthly.totalDays} ngày có dữ liệu',
          style: TextStyle(color: muted, fontSize: 14),
        ),
        const SizedBox(height: 18),
        _MonthGrid(days: monthly.days, dark: dark),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Ít', style: TextStyle(color: muted, fontSize: 10)),
            _HeatLegend(
              color: dark ? const Color(0xFF36343F) : const Color(0xFFEDEDEB),
            ),
            const _HeatLegend(color: Color(0xFFD6EBDD)),
            const _HeatLegend(color: Color(0xFFA8D0B4)),
            const _HeatLegend(color: _kAccent),
            const SizedBox(width: 5),
            Text('Nhiều', style: TextStyle(color: muted, fontSize: 10)),
          ],
        ),
      ],
    ),
  );
}

class _BmiCard extends StatelessWidget {
  final ProgressStats data;
  final Color card, border, text, muted;

  const _BmiCard({
    required this.data,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final bmi = data.bmi!;
    final category = data.bmiCategory ?? '';
    final normal = category == 'Normal';
    final marker = ((bmi - 15) / 25).clamp(0.02, 0.98);
    return _Card(
      card: card,
      border: border,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chỉ số BMI',
                  style: TextStyle(
                    color: text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.info_outline_rounded, color: muted, size: 21),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  color: text,
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 11),
              Flexible(
                child: Text(
                  category,
                  style: TextStyle(
                    color: normal ? const Color(0xFF4C9B67) : _kAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              clipBehavior: Clip.none,
              children: [
                const Row(
                  children: [
                    _BmiSegment(color: Color(0xFF78A7DF)),
                    SizedBox(width: 3),
                    _BmiSegment(color: Color(0xFF65AD7D)),
                    SizedBox(width: 3),
                    _BmiSegment(color: Color(0xFFE3B33D)),
                    SizedBox(width: 3),
                    _BmiSegment(color: Color(0xFFE36C5D)),
                  ],
                ),
                Positioned(
                  left: constraints.maxWidth * marker - 2,
                  top: -5,
                  child: Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: text,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BmiLegend(
                color: const Color(0xFF78A7DF),
                label: 'Thấp',
                value: '<18.5',
                muted: muted,
              ),
              _BmiLegend(
                color: const Color(0xFF65AD7D),
                label: 'Khỏe',
                value: '18.5–24.9',
                muted: muted,
              ),
              _BmiLegend(
                color: const Color(0xFFE3B33D),
                label: 'Cao',
                value: '25–29.9',
                muted: muted,
              ),
              _BmiLegend(
                color: const Color(0xFFE36C5D),
                label: 'Béo phì',
                value: '≥30',
                muted: muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final GoalForecast forecast;
  final Color card, border, text, muted;

  const _ForecastCard({
    required this.forecast,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => _Card(
    card: card,
    border: border,
    radius: 22,
    padding: const EdgeInsets.all(18),
    child: Row(
      children: [
        const Icon(
          Icons.track_changes_outlined,
          color: Color(0xFF36A269),
          size: 23,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dự báo mục tiêu cân nặng',
                style: TextStyle(color: text, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                forecast.display,
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ExpTab extends StatelessWidget {
  final GamificationStatus status;
  final List<Achievement> achievements;
  final Color card, border, text, muted;
  final bool dark;
  final Future<void> Function() onRefresh;

  const _ExpTab({
    required this.status,
    required this.achievements,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: _kAccent,
    onRefresh: onRefresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      children: [
        _Card(
          card: card,
          border: border,
          radius: 26,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cấp ${status.level}',
                        style: TextStyle(
                          color: text,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        GamificationStatus.levelTitle(status.level),
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '${status.exp} EXP',
                    style: const TextStyle(
                      color: Color(0xFF36A269),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: status.levelProgress.clamp(0.0, 1.0),
                  minHeight: 9,
                  backgroundColor: dark
                      ? const Color(0xFF36343F)
                      : const Color(0xFFEDEDEB),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF36A269)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                status.level >= 10
                    ? 'Bạn đã đạt cấp tối đa'
                    : '${(status.expToNextLevel - status.expInCurrentLevel).clamp(0, 100000)} EXP để lên cấp tiếp theo',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                'Hôm nay đã quét ${status.scansToday} món · tổng ${status.totalScans} lần',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionLabel('MỐC CẦN ĐẠT', muted),
        const SizedBox(height: 9),
        if (achievements.isEmpty)
          _Card(
            card: card,
            border: border,
            radius: 22,
            padding: const EdgeInsets.all(18),
            child: Text(
              'Chưa có dữ liệu mốc EXP.',
              style: TextStyle(color: muted),
            ),
          )
        else
          ...achievements.map(
            (achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AchievementTile(
                achievement: achievement,
                card: card,
                border: border,
                text: text,
                muted: muted,
                dark: dark,
              ),
            ),
          ),
      ],
    ),
  );
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final Color card, border, text, muted;
  final bool dark;

  const _AchievementTile({
    required this.achievement,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) => _Card(
    card: card,
    border: border,
    radius: 22,
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        AchievementBadge(
          id: achievement.id,
          size: 50,
          opacity: achievement.unlocked ? 1 : 0.38,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.name,
                style: TextStyle(color: text, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                achievement.description,
                style: TextStyle(color: muted, fontSize: 12),
              ),
              if (!achievement.unlocked &&
                  achievement.progressTarget != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 6,
                    backgroundColor: dark
                        ? const Color(0xFF36343F)
                        : const Color(0xFFEDEDEB),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF36A269)),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${achievement.progressCurrent ?? 0}/${achievement.progressTarget}',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
        if (achievement.unlocked)
          const Icon(Icons.check_circle, color: Color(0xFF36A269), size: 20),
      ],
    ),
  );
}

class _WeightChart extends StatelessWidget {
  final List<WeightPoint> points;
  final Color muted;
  final bool dark;

  const _WeightChart({
    required this.points,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final weights = points.map((p) => p.weightKg).toList();
    final double minW = weights.reduce((a, b) => a < b ? a : b);
    final double maxW = weights.reduce((a, b) => a > b ? a : b);
    final double margin = (maxW - minW) <= 0.5 ? 2.0 : (maxW - minW) * 0.15;
    final double yMax = maxW + margin;
    final double yMin = (minW - margin).clamp(0.0, 300.0);
    final double yMid = (yMax + yMin) / 2;

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yMax.round().toString(),
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      yMid.round().toString(),
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      yMin.round().toString(),
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomPaint(
                  painter: _WeightChartPainter(
                    points: points,
                    min: yMin,
                    max: yMax,
                    dark: dark,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildDateLabels(),
        ),
      ],
    );
  }

  List<Widget> _buildDateLabels() {
    if (points.isEmpty) return [];
    final count = points.length < 4 ? points.length : 4;
    final list = <Widget>[];
    for (int i = 0; i < count; i++) {
      final idx = points.length == 1
          ? 0
          : ((points.length - 1) * i / (count - 1)).round();
      final date = points[idx].date;
      final label = '${_monthName(date.month)} ${date.day}';
      list.add(
        Text(
          label,
          style: TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return list;
  }

  String _monthName(int month) {
    const names = [
      '',
      'Aug',
      'Aug',
      'Aug',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? names[month] : '$month';
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightPoint> points;
  final double min, max;
  final bool dark;

  const _WeightChartPainter({
    required this.points,
    required this.min,
    required this.max,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = dark ? const Color(0xFF34313D) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final y = size.height * i / 2;
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, y), Offset(startX + 4, y), gridPaint);
        startX += 8;
      }
    }

    final double spread = (max - min) <= 0.01 ? 1.0 : (max - min);
    final path = Path();
    final areaPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1);
      final norm = ((points[i].weightKg - min) / spread).clamp(0.0, 1.0);
      final y = size.height * (1.0 - norm);

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }
    areaPath.lineTo(
      points.length == 1 ? size.width / 2 : size.width,
      size.height,
    );
    areaPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF95A49).withOpacity(0.08),
          const Color(0xFFF95A49).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, fillPaint);

    final linePaint = Paint()
      ..color = dark ? Colors.white : const Color(0xFF0F172A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final lastPoint = points.last;
    final lastX = points.length == 1 ? size.width / 2 : size.width;
    final lastNorm = ((lastPoint.weightKg - min) / spread).clamp(0.0, 1.0);
    final lastY = size.height * (1.0 - lastNorm);

    final dotPaint = Paint()..color = const Color(0xFFF95A49);
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(lastX, lastY), 5, dotPaint);
    canvas.drawCircle(Offset(lastX, lastY), 5, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.min != min ||
      oldDelegate.max != max ||
      oldDelegate.dark != dark;
}

class _UnifiedNutritionChart extends StatelessWidget {
  final List<DayCaloriePoint> points;
  final Color muted;
  final bool dark;

  const _UnifiedNutritionChart({
    required this.points,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _EmptyChart(
        message: 'Chưa có đủ dữ liệu dinh dưỡng',
        muted: muted,
        height: 160,
      );
    }

    final double maxVal = points.fold<double>(0, (max, p) {
      final pCal = p.protein * 4;
      final cCal = p.carbs * 4;
      final fCal = p.fat * 9;
      final macroSum = pCal + cCal + fCal;
      final totalActual = macroSum > 0 ? macroSum : p.calo.toDouble();
      final dayMax = math.max(totalActual, p.target.toDouble());
      return dayMax > max ? dayMax : max;
    });

    final double yMax = maxVal > 0
        ? (maxVal > 1500 ? ((maxVal / 1000).ceil() * 1000.0) : 1500.0)
        : 3000.0;
    final double yMid = yMax / 2;

    final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return SizedBox(
      height: 175,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Y-Axis Scale Numbers
                SizedBox(
                  width: 38,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatYLabel(yMax),
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatYLabel(yMid),
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '0',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Stacked & Target Dual-Bar Canvas
                Expanded(
                  child: CustomPaint(
                    painter: _UnifiedStackedPainter(
                      points: points,
                      yMax: yMax,
                      dark: dark,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Day labels
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                points.isNotEmpty ? points.length : 7,
                (index) {
                  final label = index < dayLabels.length
                      ? dayLabels[index]
                      : 'T${index + 1}';
                  return Text(
                    label,
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatYLabel(double val) {
    final str = val.round().toString();
    return str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _UnifiedStackedPainter extends CustomPainter {
  final List<DayCaloriePoint> points;
  final double yMax;
  final bool dark;

  const _UnifiedStackedPainter({
    required this.points,
    required this.yMax,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Gridlines
    final gridPaint = Paint()
      ..color = dark ? const Color(0xFF34313D) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      final y = 4 + (size.height - 8) * i / 2;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) return;

    // 2. Dual Bars
    final slotWidth = size.width / points.length;
    final singleBarWidth = (slotWidth * 0.30).clamp(7.0, 15.0);
    const macroColors = [
      MacroColors.protein, // Bottom: Đạm
      MacroColors.carb,    // Middle: Carb
      MacroColors.fat,     // Top: Béo
    ];
    final targetColor =
        dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final slotCenterX = slotWidth * (i + 0.5);

      final targetBarX = slotCenterX - singleBarWidth / 2 - 1.5;
      final actualBarX = slotCenterX + singleBarWidth / 2 + 1.5;

      // Draw Target Bar (Col 1)
      final targetCal = point.target.toDouble();
      if (targetCal > 0) {
        final targetH = ((size.height - 8) * (targetCal / yMax))
            .clamp(0.0, size.height - 8);
        final targetRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(targetBarX - singleBarWidth / 2,
              size.height - 4 - targetH, singleBarWidth, targetH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(
            targetRect, Paint()..color = targetColor.withValues(alpha: 0.85));
      }

      // Draw Actual Stacked Macro Bar (Col 2)
      final pCal = point.protein * 4;
      final cCal = point.carbs * 4;
      final fCal = point.fat * 9;
      final macroSum = pCal + cCal + fCal;
      final totalCal = macroSum > 0 ? macroSum : point.calo.toDouble();

      if (totalCal > 0) {
        final totalBarHeight = ((size.height - 8) * (totalCal / yMax))
            .clamp(0.0, size.height - 8);
        var currentY = size.height - 4;

        final segmentVals = [pCal, cCal, fCal];

        for (int seg = 0; seg < segmentVals.length; seg++) {
          final val = segmentVals[seg];
          final segHeight =
              totalCal > 0 ? (totalBarHeight * (val / totalCal)) : 0.0;
          if (segHeight <= 0) continue;

          final segTop = currentY - segHeight;
          final isTopSegment = seg == segmentVals.length - 1 ||
              segmentVals.sublist(seg + 1).every((v) => v <= 0);

          final rect = RRect.fromRectAndCorners(
            Rect.fromLTWH(actualBarX - singleBarWidth / 2, segTop,
                singleBarWidth, segHeight),
            topLeft: isTopSegment ? const Radius.circular(4) : Radius.zero,
            topRight: isTopSegment ? const Radius.circular(4) : Radius.zero,
          );

          canvas.drawRRect(rect, Paint()..color = macroColors[seg]);
          currentY = segTop;
        }
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final distance = (end - start).distance;
    final dx = (end.dx - start.dx) / distance;
    final dy = (end.dy - start.dy) / distance;
    var startX = start.dx;
    var startY = start.dy;
    var rem = distance;
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    while (rem > 0) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + dx * (rem < dashWidth ? rem : dashWidth),
          startY + dy * (rem < dashWidth ? rem : dashWidth),
        ),
        paint,
      );
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
      rem -= (dashWidth + dashSpace);
    }
  }

  @override
  bool shouldRepaint(covariant _UnifiedStackedPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.yMax != yMax ||
      oldDelegate.dark != dark;
}

class _EnergyBars extends StatelessWidget {
  final List<DayCaloriePoint> points;
  final Color muted;
  final bool dark;

  const _EnergyBars({
    required this.points,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (points.every((point) => !point.hasLog)) {
      return _EmptyChart(
        message: 'Chưa có dữ liệu năng lượng',
        muted: muted,
        height: 150,
      );
    }
    final maxValue = points.fold<double>(
      1,
      (max, point) => [
        max,
        point.calo.toDouble(),
        point.target.toDouble(),
      ].reduce((a, b) => a > b ? a : b),
    );
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: points.map((point) {
          final label = point.dateKey.length >= 10
              ? point.dateKey.substring(8)
              : '';
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MiniBar(
                      value: point.calo.toDouble(),
                      max: maxValue,
                      color: _kAccent,
                    ),
                    const SizedBox(width: 3),
                    _MiniBar(
                      value: point.target.toDouble(),
                      max: maxValue,
                      color: dark ? Colors.white70 : const Color(0xFF111318),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('T$label', style: TextStyle(color: muted, fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final List<DayLogPoint> days;
  final bool dark;

  const _MonthGrid({required this.days, required this.dark});

  @override
  Widget build(BuildContext context) {
    final empty = dark ? const Color(0xFF36343F) : const Color(0xFFEDEDEB);
    if (days.isEmpty) {
      return Text(
        'Chưa có dữ liệu',
        style: TextStyle(color: dark ? Colors.white70 : Colors.black54),
      );
    }

    final firstDate = DateTime.tryParse(days.first.dateKey);
    final leading = firstDate == null ? 0 : firstDate.weekday - 1;
    final weekCount = ((leading + days.length) / 7).ceil();

    Color cellColor(int count) {
      if (count <= 0) return empty;
      if (count == 1) return const Color(0xFFD6EBDD);
      if (count == 2) return const Color(0xFFA8D0B4);
      return _kAccent;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              const SizedBox(height: 2),
              ...['T2', '', 'T4', '', 'T6', '', 'CN'].map(
                (label) => SizedBox(
                  height: 19,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: dark ? Colors.white54 : Colors.black45,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: weekCount * 21.0,
              child: Column(
                children: List.generate(
                  7,
                  (weekday) => SizedBox(
                    height: 19,
                    child: Row(
                      children: List.generate(weekCount, (week) {
                        final index = week * 7 + weekday - leading;
                        final point = index >= 0 && index < days.length
                            ? days[index]
                            : null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 5, bottom: 5),
                          child: SizedBox(
                            width: 16,
                            height: 14,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: point == null
                                    ? Colors.transparent
                                    : cellColor(point.scanCount),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double value, max;
  final Color color;

  const _MiniBar({required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: value <= 0 ? 3 : 105 * (value / max).clamp(.04, 1.0),
    decoration: BoxDecoration(
      color: value <= 0 ? color.withValues(alpha: .16) : color,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

class _RangeSelector extends StatelessWidget {
  final int value;
  final bool dark;
  final ValueChanged<int> onChanged;

  const _RangeSelector({
    required this.value,
    required this.dark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = <int, String>{90: '90D', 180: '6M', 365: '1Y', 3650: 'ALL'};
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2C2A34) : const Color(0xFFF1F1EF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: options.entries
            .map(
              (entry) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == entry.key
                          ? (dark ? const Color(0xFF4A4653) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: value == entry.key
                          ? const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: value == entry.key
                            ? (dark ? Colors.white : const Color(0xFF111318))
                            : (dark ? Colors.white70 : const Color(0xFF747780)),
                        fontSize: 12,
                        fontWeight: value == entry.key
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MacroMetric extends StatelessWidget {
  final String label, value, unit;
  final Color color, text, muted;

  const _MacroMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 4),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: ' $unit',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _EnergyMetric extends StatelessWidget {
  final String label, value;
  final Color color, muted;

  const _EnergyMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          letterSpacing: -.5,
        ),
      ),
      Text('kcal/ngày', style: TextStyle(color: muted, fontSize: 10)),
    ],
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color muted;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: muted, fontSize: 12)),
    ],
  );
}

class _ProgressPill extends StatelessWidget {
  final String text;
  final bool dark;

  const _ProgressPill({required this.text, required this.dark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF24352A) : _kAccentSoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: dark ? const Color(0xFFA8D0B4) : const Color(0xFF3D7F56),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
    ),
  );
}

class _Kicker extends StatelessWidget {
  final String label;
  final Color color;

  const _Kicker(this.label, this.color);

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );
}

class _BmiSegment extends StatelessWidget {
  final Color color;

  const _BmiSegment({required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}

class _BmiLegend extends StatelessWidget {
  final Color color;
  final String label, value;
  final Color muted;

  const _BmiLegend({
    required this.color,
    required this.label,
    required this.value,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => Flexible(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: muted, fontSize: 9)),
      ],
    ),
  );
}

class _EmptyChart extends StatelessWidget {
  final String message;
  final Color muted;
  final double height;

  const _EmptyChart({
    required this.message,
    required this.muted,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: Text(message, style: TextStyle(color: muted, fontSize: 13)),
    ),
  );
}

class _Card extends StatelessWidget {
  final Color card, border;
  final double radius;
  final EdgeInsets padding;
  final Widget child;

  const _Card({
    required this.card,
    required this.border,
    required this.radius,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: card,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07111418),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
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

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;
  final Color text, muted;

  const _ErrorState({
    required this.onRetry,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Không tải được dữ liệu',
          style: TextStyle(color: text, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onRetry,
          child: Text('Thử lại', style: TextStyle(color: muted)),
        ),
      ],
    ),
  );
}

class _WeightChangeCard extends StatelessWidget {
  final List<WeightChangeItem> changes;
  final Color card, border, text, muted;
  final bool dark;
  final VoidCallback? onLogWeight;

  const _WeightChangeCard({
    required this.changes,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
    this.onLogWeight,
  });

  @override
  Widget build(BuildContext context) {
    final items = changes
        .where((item) => item.sparkline.length >= 2 || item.diffKg.abs() > 0.01)
        .toList();

    return _Card(
      card: card,
      border: border,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thay đổi cân nặng',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (onLogWeight != null)
                InkWell(
                  onTap: onLogWeight,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF63A97B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF63A97B).withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: Color(0xFF63A97B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Ghi cân nặng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF63A97B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ghi cân nặng ít nhất hai lần để xem thay đổi theo thời gian.',
                    style: TextStyle(color: muted, fontSize: 14, height: 1.4),
                  ),
                  if (onLogWeight != null) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: onLogWeight,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63A97B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Ghi cân nặng ngay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            ...items.map((item) {
              final isLoss = item.diffKg <= 0;
              final absDiff = item.diffKg.abs().toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Expanded(
                      child: SizedBox(
                        height: 24,
                        child: CustomPaint(
                          painter: _WeightSparklinePainter(
                            values: item.sparkline,
                            color: const Color(0xFFF95A49),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Text(
                      '${item.diffKg.abs() <= 0.01
                          ? ""
                          : item.diffKg > 0
                          ? "+"
                          : "-"}$absDiff kg',
                      style: TextStyle(
                        color: text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoss
                              ? Icons.call_received_rounded
                              : Icons.call_made_rounded,
                          size: 15,
                          color: isLoss
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isLoss ? 'Giảm' : 'Tăng',
                          style: TextStyle(
                            color: isLoss
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _WeightSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _WeightSparklinePainter({
    required this.values,
    this.color = const Color(0xFFF95A49),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final double minV = values.reduce((a, b) => a < b ? a : b);
    final double maxV = values.reduce((a, b) => a > b ? a : b);
    final double spread = (maxV - minV) <= 0.01 ? 1.0 : (maxV - minV);

    final path = Path();
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final norm = (values[i] - minV) / spread;
      final y = size.height - (norm * (size.height - 4) + 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WeightSparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class _LogWeightResult {
  final double weightKg;
  final DateTime date;
  final String? photoPath;

  _LogWeightResult({
    required this.weightKg,
    required this.date,
    this.photoPath,
  });
}

class _LogWeightModalSheet extends StatefulWidget {
  final double initialWeight;
  final double? lastWeight;
  final bool isDark;

  const _LogWeightModalSheet({
    required this.initialWeight,
    this.lastWeight,
    required this.isDark,
  });

  @override
  State<_LogWeightModalSheet> createState() => _LogWeightModalSheetState();
}

class _LogWeightModalSheetState extends State<_LogWeightModalSheet> {
  late double _weight;
  late DateTime _selectedDate;
  String? _selectedPhotoPath;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight.clamp(30.0, 250.0);
    _selectedDate = DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedPhotoPath = image.path);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF1E1D24) : Colors.white;
    final textDark = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = widget.isDark
        ? const Color(0xFFA0A0AB)
        : const Color(0xFF64748B);
    final cardBg = widget.isDark
        ? const Color(0xFF2A2932)
        : const Color(0xFFF8F9FA);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Cân nặng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _weight.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'kg',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            'Lần gần nhất: ${widget.lastWeight != null ? "${widget.lastWeight!.toStringAsFixed(1)} kg" : "${_weight.toStringAsFixed(1)} kg"}',
            style: TextStyle(fontSize: 14, color: textMuted),
          ),
          const SizedBox(height: 20),

          HorizontalRulerPicker(
            min: 30.0,
            max: 250.0,
            initialValue: _weight,
            step: 0.1,
            needleColor: const Color(0xFFF95A49),
            onChanged: (val) {
              setState(() {
                _weight = (val * 10).round() / 10;
              });
            },
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngày',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF3B3947)
                          : const Color(0xFFEBECEF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'ngày ${_selectedDate.day} thg ${_selectedDate.month}, ${_selectedDate.year}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 20, color: textDark),
                    const SizedBox(width: 10),
                    Text(
                      'Thêm ảnh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Row(
                    children: [
                      Text(
                        _selectedPhotoPath != null ? 'Đã chọn ảnh' : 'Tuỳ chọn',
                        style: TextStyle(fontSize: 14, color: textMuted),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _LogWeightResult(
                    weightKg: _weight,
                    date: _selectedDate,
                    photoPath: _selectedPhotoPath,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDark
                    ? Colors.white
                    : const Color(0xFF0F172A),
                foregroundColor: widget.isDark
                    ? const Color(0xFF0F172A)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ghi cân nặng',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
