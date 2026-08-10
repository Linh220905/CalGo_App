import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../providers/scan_task_provider.dart';
import 'ad_banner.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  ScanTaskProvider? _scanTasks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scanTasks = context.read<ScanTaskProvider>();
    if (_scanTasks == scanTasks) return;
    _scanTasks?.removeListener(_openCompletedScan);
    _scanTasks = scanTasks..addListener(_openCompletedScan);
    _openCompletedScan();
  }

  @override
  void dispose() {
    _scanTasks?.removeListener(_openCompletedScan);
    super.dispose();
  }

  void _openCompletedScan() {
    final task = _scanTasks?.completedTask;
    final resultId = task?.resultId;
    if (!mounted || task == null || resultId == null) return;
    _scanTasks!.consumeCompleted(task.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshUser();
      context.read<HomeProvider>().loadToday(forceRefresh: true);
      context.push('/result/$resultId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;

    int currentIndex;
    switch (location) {
      case '/home':
        currentIndex = 0;
      case '/history':
        currentIndex = 1;
      case '/profile':
        currentIndex = 2;
      default:
        currentIndex = 0; // Default to Home
    }

    final barBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final selectedColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final unselectedColor =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: barBgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CalGoAdBanner(),
            BottomNavigationBar(
              currentIndex: currentIndex,
              backgroundColor: barBgColor,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go('/home');
                  case 1:
                    context.go('/history');
                  case 2:
                    context.go('/profile');
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_filled),
                  label: s.tabHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: s.tabAnalytics,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_rounded),
                  label: s.tabSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
