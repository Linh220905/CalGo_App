import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

enum QuickAddAction { exercise, scanMeal }

enum ExerciseEntryType { running, walking, cycling, swimming, workout, manual }

Future<QuickAddAction?> showQuickAddSheet(
  BuildContext context, {
  required bool isDark,
}) {
  return showGeneralDialog<QuickAddAction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'QuickAddPopup',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return _QuickAddPopup(isDark: isDark);
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
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

class _QuickAddPopup extends StatelessWidget {
  final bool isDark;

  const _QuickAddPopup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final shadowColor =
        isDark ? const Color(0x50000000) : const Color(0x1C0F172A);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Backdrop click dismiss
            GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),

            // Popup floating cards positioned above bottom right FAB
            Positioned(
              right: 20,
              bottom: 16,
              left: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2 Cards Side-by-Side
                  Row(
                    children: [
                      // Card 1: Ghi tập luyện
                      Expanded(
                        child: _QuickAddTile(
                          icon: Icons.fitness_center_rounded,
                          title: strings.logWorkoutTile,
                          cardBg: cardBg,
                          textDark: textDark,
                          shadowColor: shadowColor,
                          onTap: () => Navigator.pop(context, QuickAddAction.exercise),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Card 2: Quét món ăn
                      Expanded(
                        child: _QuickAddTile(
                          icon: Icons.crop_free_rounded,
                          title: strings.scanMealTile,
                          cardBg: cardBg,
                          textDark: textDark,
                          shadowColor: shadowColor,
                          onTap: () => Navigator.pop(context, QuickAddAction.scanMeal),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Floating Close (X) button aligned with FAB
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        size: 28,
                      ),
                    ),
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

class _QuickAddTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color cardBg;
  final Color textDark;
  final Color shadowColor;
  final VoidCallback onTap;

  const _QuickAddTile({
    required this.icon,
    required this.title,
    required this.cardBg,
    required this.textDark,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: textDark),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTypeSheet extends StatelessWidget {
  final bool isDark;

  const _ExerciseTypeSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    return _SheetFrame(
      isDark: isDark,
      title: strings.logWorkoutTile,
      subtitle: strings.chooseExerciseTypeSubtitle,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _TypeTile(
              icon: Icons.directions_run_rounded,
              title: strings.exerciseRunning,
              subtitle: strings.exerciseRunningDesc,
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.running),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.directions_walk_rounded,
              title: strings.exerciseWalking,
              subtitle: strings.exerciseWalkingDesc,
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.walking),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.directions_bike_rounded,
              title: strings.exerciseCycling,
              subtitle: strings.exerciseCyclingDesc,
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.cycling),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.pool_rounded,
              title: strings.exerciseSwimming,
              subtitle: strings.exerciseSwimmingDesc,
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.swimming),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.fitness_center_rounded,
              title: strings.exerciseWorkout,
              subtitle: strings.exerciseWorkoutDesc,
              isDark: isDark,
              onTap: () => Navigator.pop(context, ExerciseEntryType.workout),
            ),
            const SizedBox(height: 10),
            _TypeTile(
              icon: Icons.edit_note_rounded,
              title: strings.exerciseManual,
              subtitle: strings.exerciseManualDesc,
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
