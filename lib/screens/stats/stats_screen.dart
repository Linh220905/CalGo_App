import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/gamification.dart';
import '../../models/progress.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/achievement_badge.dart';

const _kAccent = Color(0xFFFF6B35);
const _kProtein = Color(0xFFFF6257);
const _kCarbs = Color(0xFFF6B722);
const _kFat = Color(0xFF7B4DDE);

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
    final bg = dark ? const Color(0xFF141318) : const Color(0xFFF7F7F5);
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

  const _StatsTabBar({
    required this.controller,
    required this.card,
    required this.text,
    required this.muted,
    required this.border,
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
          color: const Color(0xFFFFE5D8),
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
        tabs: const [
          Tab(text: 'Tiến trình'),
          Tab(text: 'EXP & mục tiêu'),
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
  final ImagePicker _picker = ImagePicker();
  int _weightRangeDays = 90;

  Future<void> _selectWeightRange(int days) async {
    if (_weightRangeDays == days || widget.progress.loading) return;
    setState(() => _weightRangeDays = days);
    await widget.progress.refresh(days: days);
  }

  Future<void> _pickProgressPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 92,
    );
    if (picked == null || !mounted) return;
    final saved = await widget.progress.uploadPhoto(picked.path);
    if (!mounted) return;
    _showMessage(
      saved ? 'Đã lưu ảnh tiến trình' : 'Không thể lưu ảnh. Vui lòng thử lại.',
    );
  }

  Future<void> _showWeightDialog() async {
    final current = widget.progress.data?.currentWeightKg;
    final controller = TextEditingController(
      text: current == null ? '' : current.toStringAsFixed(1),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ghi cân nặng'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Cân nặng hôm nay',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.read<AppSettingsProvider>().strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(
                controller.text.replaceAll(',', '.'),
              );
              if (parsed == null || parsed < 20 || parsed > 300) return;
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    final saved = await widget.progress.logWeight(value);
    if (!mounted) return;
    _showMessage(
      saved
          ? 'Đã cập nhật cân nặng'
          : 'Không thể lưu cân nặng. Vui lòng thử lại.',
    );
  }

  Future<void> _confirmDeletePhoto(ProgressPhoto photo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa ảnh tiến trình?'),
        content: const Text('Ảnh này sẽ bị xóa khỏi tài khoản của bạn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.read<AppSettingsProvider>().strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    final deleted = await widget.progress.deletePhoto(photo.id);
    if (!mounted || deleted) return;
    _showMessage('Không thể xóa ảnh. Vui lòng thử lại.');
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
          const SizedBox(height: 24),
          _SectionLabel('CÂN NẶNG', widget.muted),
          const SizedBox(height: 9),
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
          const SizedBox(height: 24),
          _SectionLabel('HÌNH ẢNH', widget.muted),
          const SizedBox(height: 9),
          _ProgressPhotoCard(
            photos: data?.progressPhotos ?? const [],
            card: widget.card,
            border: widget.border,
            text: widget.text,
            muted: widget.muted,
            dark: widget.dark,
            api: context.read<ApiService>(),
            mutating: widget.progress.mutating,
            onUpload: _pickProgressPhoto,
            onDelete: _confirmDeletePhoto,
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
            _EnergyCard(
              weekly: widget.weekly!,
              card: widget.card,
              border: widget.border,
              text: widget.text,
              muted: widget.muted,
              dark: widget.dark,
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
    final target = data?.targetWeightKg;
    final start = data?.startWeightKg;
    final progress = ((data?.progressPercent ?? 0) / 100).clamp(0.0, 1.0);
    final hasProgress = data?.progressPercent != null;

    return _Card(
      card: card,
      border: border,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
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
                        Text(
                          'kg',
                          style: TextStyle(color: muted, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onLogWeight,
                style: FilledButton.styleFrom(
                  backgroundColor: dark
                      ? Colors.white
                      : const Color(0xFF111318),
                  foregroundColor: dark
                      ? const Color(0xFF111318)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ghi cân nặng',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: hasProgress ? progress : 0,
              minHeight: 8,
              backgroundColor: dark
                  ? const Color(0xFF36343F)
                  : const Color(0xFFEDEDEB),
              valueColor: const AlwaysStoppedAnimation(_kAccent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ValueLabel('BẮT ĐẦU', start, muted, text),
              _ValueLabel('MỤC TIÊU', target, muted, text, alignEnd: true),
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
              _ProgressPill(
                text: percent == null
                    ? 'Chưa đủ dữ liệu'
                    : '${percent.toStringAsFixed(0)}% mục tiêu',
                dark: dark,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            points.length < 2
                ? 'Ghi ít nhất 2 lần để xem biểu đồ.'
                : '${points.length} lần ghi trong ${rangeDays >= 365 ? '${(rangeDays / 365).round()} năm' : '${(rangeDays / 30).round()} tháng'}.',
            style: TextStyle(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          if (loading)
            const SizedBox(
              height: 138,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (points.length < 2)
            _EmptyChart(
              message: 'Chưa có đủ dữ liệu cân nặng',
              muted: muted,
              height: 138,
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

class _ProgressPhotoCard extends StatelessWidget {
  final List<ProgressPhoto> photos;
  final Color card, border, text, muted;
  final bool dark, mutating;
  final ApiService api;
  final VoidCallback onUpload;
  final Future<void> Function(ProgressPhoto photo) onDelete;

  const _ProgressPhotoCard({
    required this.photos,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.dark,
    required this.api,
    required this.mutating,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      card: card,
      border: border,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ảnh tiến trình',
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (photos.isEmpty)
            Row(
              children: [
                _PhotoPlaceholder(dark: dark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theo dõi thay đổi của bạn theo thời gian.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: mutating ? null : onUpload,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Tải ảnh lên'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: text,
                          side: BorderSide(color: border, width: 1.4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 154,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return _PhotoTile(
                        photo: photo,
                        api: api,
                        dark: dark,
                        onDelete: () => onDelete(photo),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: mutating ? null : onUpload,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Thêm ảnh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: text,
                      side: BorderSide(color: border, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NutritionSummaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  'Dinh dưỡng trung bình',
                  style: TextStyle(
                    color: text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ProgressPill(text: '${weekly.daysLogged}/7 ngày', dark: dark),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Dữ liệu từ các bữa ăn bạn đã ghi nhận.',
            style: TextStyle(color: muted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MacroMetric(
                  label: 'Calo',
                  value: '${weekly.avgCalo.round()}',
                  unit: 'kcal',
                  color: _kAccent,
                  text: text,
                  muted: muted,
                ),
              ),
              Expanded(
                child: _MacroMetric(
                  label: 'Đạm',
                  value: weekly.avgProtein.toStringAsFixed(1),
                  unit: 'g',
                  color: _kProtein,
                  text: text,
                  muted: muted,
                ),
              ),
              Expanded(
                child: _MacroMetric(
                  label: 'Carb',
                  value: weekly.avgCarb.toStringAsFixed(1),
                  unit: 'g',
                  color: _kCarbs,
                  text: text,
                  muted: muted,
                ),
              ),
              Expanded(
                child: _MacroMetric(
                  label: 'Béo',
                  value: weekly.avgFat.toStringAsFixed(1),
                  unit: 'g',
                  color: _kFat,
                  text: text,
                  muted: muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MacroChart(points: weekly.dailyPoints, muted: muted, dark: dark),
        ],
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
            const _HeatLegend(color: Color(0xFFFFD6C7)),
            const _HeatLegend(color: Color(0xFFFF9D79)),
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
    final min = points
        .map((point) => point.weightKg)
        .reduce((a, b) => a < b ? a : b);
    final max = points
        .map((point) => point.weightKg)
        .reduce((a, b) => a > b ? a : b);
    final spread = (max - min).clamp(1.0, 20.0);
    return SizedBox(
      height: 138,
      child: CustomPaint(
        painter: _WeightChartPainter(
          points: points,
          min: min - spread * .15,
          max: max + spread * .15,
          dark: dark,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: points
              .map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${point.date.day}/${point.date.month}',
                    style: TextStyle(color: muted, fontSize: 9),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
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
    final grid = Paint()
      ..color = dark ? const Color(0xFF34313D) : const Color(0xFFF0F0EE)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = 10 + (size.height - 32) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final line = Paint()
      ..color = _kAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = _kAccent.withValues(alpha: .12);
    final path = Path();
    final area = Path();
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1);
      final normalized = ((points[i].weightKg - min) / (max - min)).clamp(
        0.0,
        1.0,
      );
      final y = 10 + (size.height - 32) * (1 - normalized);
      if (i == 0) {
        path.moveTo(x, y);
        area.moveTo(x, size.height - 22);
        area.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    area.lineTo(size.width, size.height - 22);
    area.close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, line);
    final dot = Paint()..color = _kAccent;
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1);
      final normalized = ((points[i].weightKg - min) / (max - min)).clamp(
        0.0,
        1.0,
      );
      final y = 10 + (size.height - 32) * (1 - normalized);
      canvas.drawCircle(Offset(x, y), 5, dot);
      canvas.drawCircle(Offset(x, y), 5, ring);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.min != min ||
      oldDelegate.max != max ||
      oldDelegate.dark != dark;
}

class _MacroChart extends StatelessWidget {
  final List<DayCaloriePoint> points;
  final Color muted;
  final bool dark;

  const _MacroChart({
    required this.points,
    required this.muted,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (points.every(
      (point) => point.protein == 0 && point.carbs == 0 && point.fat == 0,
    )) {
      return _EmptyChart(
        message: 'Chưa có đủ dữ liệu macro',
        muted: muted,
        height: 150,
      );
    }
    final maxValue = points.fold<double>(1, (max, point) {
      final value = [
        point.protein,
        point.carbs,
        point.fat,
      ].reduce((a, b) => a > b ? a : b);
      return max > value ? max : value;
    });
    return SizedBox(
      height: 170,
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
                      value: point.protein,
                      max: maxValue,
                      color: _kProtein,
                    ),
                    const SizedBox(width: 2),
                    _MiniBar(value: point.carbs, max: maxValue, color: _kCarbs),
                    const SizedBox(width: 2),
                    _MiniBar(value: point.fat, max: maxValue, color: _kFat),
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
      if (count == 1) return const Color(0xFFFFD6C7);
      if (count == 2) return const Color(0xFFFF9D79);
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

class _PhotoTile extends StatelessWidget {
  final ProgressPhoto photo;
  final ApiService api;
  final bool dark;
  final VoidCallback onDelete;

  const _PhotoTile({
    required this.photo,
    required this.api,
    required this.dark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 116,
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Image.network(
            photo.thumbnailUrl,
            width: 116,
            height: 154,
            fit: BoxFit.cover,
            headers: api.authHeaders,
            errorBuilder: (_, __, ___) => Container(
              color: dark ? const Color(0xFF36343F) : const Color(0xFFEDEDEB),
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          left: 7,
          right: 7,
          bottom: 7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .56),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              child: Text(
                '${photo.capturedDate.day}/${photo.capturedDate.month}/${photo.capturedDate.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            tooltip: 'Xóa ảnh',
            onPressed: onDelete,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 18,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: .48),
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PhotoPlaceholder extends StatelessWidget {
  final bool dark;

  const _PhotoPlaceholder({required this.dark});

  @override
  Widget build(BuildContext context) => Container(
    width: 116,
    height: 116,
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF2C2A34) : const Color(0xFFF1F1EF),
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.photo_camera_outlined,
      color: dark ? Colors.white70 : const Color(0xFF777780),
      size: 42,
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
    const options = <int, String>{90: '90 ngày', 180: '6 tháng', 365: '1 năm'};
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
      color: dark ? const Color(0xFF3B2A34) : const Color(0xFFFFE5D8),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: dark ? const Color(0xFFFFB092) : const Color(0xFFB84C25),
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

class _ValueLabel extends StatelessWidget {
  final String label;
  final double? value;
  final Color muted, text;
  final bool alignEnd;

  const _ValueLabel(
    this.label,
    this.value,
    this.muted,
    this.text, {
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: muted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value == null ? '--' : '${value!.toStringAsFixed(1)} kg',
        style: TextStyle(
          color: text,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
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
