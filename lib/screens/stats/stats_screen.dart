import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/gamification.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thống kê & Tiến trình',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              labelColor: isDark ? Colors.black : Colors.white,
              unselectedLabelColor: textMuted,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.all(3),
              tabs: const [
                Tab(text: '7 Ngày'),
                Tab(text: '30 Ngày'),
                Tab(text: 'Dinh dưỡng'),
                Tab(text: 'Dự báo'),
                Tab(text: 'Thành tích'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _Tab7Days(isDark: isDark, cardBg: cardBgColor, border: borderColor, textDark: textDark, textMuted: textMuted),
          _Tab30Days(isDark: isDark, cardBg: cardBgColor, border: borderColor, textDark: textDark, textMuted: textMuted),
          _TabNutrition(isDark: isDark, cardBg: cardBgColor, border: borderColor, textDark: textDark, textMuted: textMuted),
          _TabForecast(isDark: isDark, cardBg: cardBgColor, border: borderColor, textDark: textDark, textMuted: textMuted),
          _TabAchievements(isDark: isDark, cardBg: cardBgColor, border: borderColor, textDark: textDark, textMuted: textMuted),
        ],
      ),
    );
  }
}

// ── Tab 1: 7 Days Summary ──────────────────────────────────────
class _Tab7Days extends StatelessWidget {
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _Tab7Days({
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Overview Cards Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Calo TB/ngày',
                  value: '1,850',
                  unit: 'kcal',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFF97316),
                  cardBg: cardBg,
                  border: border,
                  textDark: textDark,
                  textMuted: textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Protein TB',
                  value: '95g',
                  unit: '88% goal',
                  icon: Icons.fitness_center_rounded,
                  iconColor: const Color(0xFFFF5C5C),
                  cardBg: cardBg,
                  border: border,
                  textDark: textDark,
                  textMuted: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12, height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Ngày đã ghi',
                  value: '6/7',
                  unit: 'ngày',
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  cardBg: cardBg,
                  border: border,
                  textDark: textDark,
                  textMuted: textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Streak',
                  value: '5',
                  unit: 'ngày liên tiếp',
                  icon: Icons.bolt_rounded,
                  iconColor: const Color(0xFFEAB308),
                  cardBg: cardBg,
                  border: border,
                  textDark: textDark,
                  textMuted: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Lượng Calo 7 Ngày Vừa Qua',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 12),
          _BarChartCard(
            cardBg: cardBg,
            border: border,
            textDark: textDark,
            textMuted: textMuted,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: 30 Days Adherence ──────────────────────────────────
class _Tab30Days extends StatelessWidget {
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _Tab30Days({
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tỷ lệ kỷ luật', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMuted)),
                    Text('83%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF22C55E))),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Bạn đã ghi chép 25/30 ngày gần đây', style: TextStyle(fontSize: 13, color: textDark)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 25 / 30,
                    minHeight: 8,
                    backgroundColor: isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Ma Trận Đều Đặn (30 Ngày)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 12),
          _HeatmapGrid(cardBg: cardBg, border: border, isDark: isDark),
        ],
      ),
    );
  }
}

// ── Tab 3: Nutrition Ratios ────────────────────────────────────
class _TabNutrition extends StatelessWidget {
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _TabNutrition({
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tỷ lệ Macronutrients trung bình', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MacroPieSegment(label: 'Protein', pct: '30%', color: const Color(0xFFFF5C5C), textDark: textDark),
                    _MacroPieSegment(label: 'Carbs', pct: '45%', color: const Color(0xFFF59E0B), textDark: textDark),
                    _MacroPieSegment(label: 'Fat', pct: '25%', color: const Color(0xFF3B82F6), textDark: textDark),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: const [
                      Expanded(flex: 30, child: SizedBox(height: 10, child: ColoredBox(color: Color(0xFFFF5C5C)))),
                      Expanded(flex: 45, child: SizedBox(height: 10, child: ColoredBox(color: Color(0xFFF59E0B)))),
                      Expanded(flex: 25, child: SizedBox(height: 10, child: ColoredBox(color: Color(0xFF3B82F6)))),
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

// ── Tab 4: Goal Forecast ───────────────────────────────────────
class _TabForecast extends StatelessWidget {
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _TabForecast({
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: Color(0xFF22C55E), size: 24),
                    const SizedBox(width: 10),
                    Text('Dự Báo Tốc Độ Thay Đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Dựa trên trung bình 7 ngày qua (-420 kcal/ngày deficit):',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141318) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ước tính chạm mục tiêu:', style: TextStyle(fontSize: 13, color: textMuted)),
                      Text('3 – 5 tuần tới', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textDark)),
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

// ── Tab 5: Achievements & Levels ──────────────────────────────
class _TabAchievements extends StatelessWidget {
  final bool isDark;
  final Color cardBg, border, textDark, textMuted;

  const _TabAchievements({
    required this.isDark,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cấp độ 3', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textDark)),
                        Text(GamificationStatus.levelTitle(3), style: TextStyle(fontSize: 13, color: textMuted)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('245 / 400 EXP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 245 / 400,
                    minHeight: 8,
                    backgroundColor: isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Huy Hiệu Đã Đạt Được', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _BadgeTile(icon: '🔥', title: 'Khởi đầu rực rỡ', unlocked: true, cardBg: cardBg, border: border, textDark: textDark),
              _BadgeTile(icon: '📸', title: 'Chuyên gia Scan', unlocked: true, cardBg: cardBg, border: border, textDark: textDark),
              _BadgeTile(icon: '🥩', title: 'Vua Protein', unlocked: true, cardBg: cardBg, border: border, textDark: textDark),
              _BadgeTile(icon: '⚡', title: '7 Ngày Siêu Cấp', unlocked: false, cardBg: cardBg, border: border, textDark: textDark),
              _BadgeTile(icon: '🏆', title: 'Chiến Thắng Calo', unlocked: false, cardBg: cardBg, border: border, textDark: textDark),
              _BadgeTile(icon: '👑', title: 'Huyền Thoại CalGo', unlocked: false, cardBg: cardBg, border: border, textDark: textDark),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Sub-widgets ──────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color iconColor, cardBg, border, textDark, textMuted;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textDark, height: 1.0)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: textMuted)),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final Color cardBg, border, textDark, textMuted;
  final bool isDark;

  const _BarChartCard({
    required this.cardBg,
    required this.border,
    required this.textDark,
    required this.textMuted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final heights = [0.75, 0.90, 0.60, 0.85, 0.95, 0.70, 0.80];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 100 * heights[index],
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(days[index], style: TextStyle(fontSize: 11, color: textMuted)),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final Color cardBg, border;
  final bool isDark;

  const _HeatmapGrid({required this.cardBg, required this.border, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: List.generate(30, (i) {
          final isLogged = i % 4 != 0;
          return Container(
            decoration: BoxDecoration(
              color: isLogged
                  ? const Color(0xFF22C55E).withOpacity(0.2 + (i % 3) * 0.25)
                  : (isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}

class _MacroPieSegment extends StatelessWidget {
  final String label, pct;
  final Color color, textDark;

  const _MacroPieSegment({required this.label, required this.pct, required this.color, required this.textDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(pct, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String icon, title;
  final bool unlocked;
  final Color cardBg, border, textDark;

  const _BadgeTile({
    required this.icon,
    required this.title,
    required this.unlocked,
    required this.cardBg,
    required this.border,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1.0 : 0.3,
            child: Text(icon, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: unlocked ? textDark : const Color(0xFF8E8D9A),
            ),
          ),
        ],
      ),
    );
  }
}
