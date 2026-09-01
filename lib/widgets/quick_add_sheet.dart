import 'package:flutter/material.dart';

enum QuickAddAction { exercise, scanMeal }

enum ExerciseEntryType { running, walking, cycling, swimming, workout, manual }

Future<QuickAddAction?> showQuickAddSheet(
  BuildContext context, {
  required bool isDark,
}) {
  return showModalBottomSheet<QuickAddAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _QuickAddSheet(isDark: isDark),
  );
}

Future<ExerciseEntryType?> showExerciseTypeSheet(
  BuildContext context, {
  required bool isDark,
}) {
  return showModalBottomSheet<ExerciseEntryType>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _ExerciseTypeSheet(isDark: isDark),
  );
}

class _QuickAddSheet extends StatelessWidget {
  final bool isDark;

  const _QuickAddSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      isDark: isDark,
      title: 'Bạn muốn ghi gì?',
      subtitle: 'Theo dõi năng lượng vào và năng lượng đã đốt.',
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              icon: Icons.fitness_center_rounded,
              title: 'Ghi tập luyện',
              subtitle: 'Chạy bộ, đi bộ, đạp xe, bơi lội...',
              isDark: isDark,
              onTap: () => Navigator.pop(context, QuickAddAction.exercise),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              icon: Icons.document_scanner_outlined,
              title: 'Quét món ăn',
              subtitle: 'Chụp ảnh để phân tích dinh dưỡng',
              isDark: isDark,
              onTap: () => Navigator.pop(context, QuickAddAction.scanMeal),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTypeSheet extends StatelessWidget {
  final bool isDark;

  const _ExerciseTypeSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      isDark: isDark,
      title: 'Ghi tập luyện',
      subtitle: 'Chọn cách tính calo đã đốt.',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _TypeTile(
              icon: Icons.directions_run_rounded,
              title: 'Chạy bộ',
              subtitle: 'Ước tính theo tốc độ, cân nặng và thời lượng',
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.running),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.directions_walk_rounded,
              title: 'Đi bộ',
              subtitle: 'Ước tính theo tốc độ đi dạo hoặc đi nhanh',
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.walking),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.directions_bike_rounded,
              title: 'Đạp xe',
              subtitle: 'Ước tính theo tốc độ đạp nhẹ hoặc gắng sức',
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.cycling),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.pool_rounded,
              title: 'Bơi lội',
              subtitle: 'Bơi sải, bơi ếch theo mức độ gắng sức',
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.swimming),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.fitness_center_rounded,
              title: 'Tập luyện (Gym)',
              subtitle: 'Kháng lực hoặc circuit theo cường độ',
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.workout),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.edit_note_rounded,
              title: 'Ghi thủ công',
              subtitle: 'Nhập số calo từ máy tập hoặc thiết bị khác',
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.manual),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final Widget child;

  const _SheetFrame({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E1C24) : const Color(0xFFF7F7F8);
    final text = isDark ? Colors.white : const Color(0xFF111111);
    final muted = isDark ? const Color(0xFFA3A0AA) : const Color(0xFF6B7280);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: muted, fontSize: 14)),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF111111);
    final muted = isDark ? const Color(0xFFA3A0AA) : const Color(0xFF6B7280);
    return Material(
      color: isDark ? const Color(0xFF292731) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: text),
              const SizedBox(height: 30),
              Text(
                title,
                style: TextStyle(
                  color: text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: muted, fontSize: 12.5, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : const Color(0xFF111111);
    final muted = isDark ? const Color(0xFFA3A0AA) : const Color(0xFF6B7280);
    return Material(
      color: isDark ? const Color(0xFF292731) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF2F2F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: text),
        ),
        title: Text(
          title,
          style: TextStyle(color: text, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: muted, fontSize: 12.5),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: muted),
      ),
    );
  }
}
