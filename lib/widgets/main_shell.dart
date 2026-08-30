import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../providers/scan_task_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/exp_gain_toast.dart';
import 'ad_banner.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  ScanTaskProvider? _scanTasks;
  DateTime _lastKnownDay = _dayOnly(DateTime.now());
  bool _resumeRefreshInFlight = false;
  bool _rewardDisplayScheduled = false;

  static DateTime _dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

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
    WidgetsBinding.instance.removeObserver(this);
    _scanTasks?.removeListener(_openCompletedScan);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshSessionAndHome());
    }
  }

  Future<void> _refreshSessionAndHome() async {
    if (_resumeRefreshInFlight || !mounted) return;
    _resumeRefreshInFlight = true;

    try {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) return;

      final today = _dayOnly(DateTime.now());
      final crossedDayBoundary = today != _lastKnownDay;
      _lastKnownDay = today;

      // Refresh first. HomeService must not race a stale access token while
      // reloading the dashboard after an overnight iOS suspension.
      await auth.refreshTokenSilently();
      if (!mounted || !auth.isAuthenticated) return;

      final home = context.read<HomeProvider>();
      if (crossedDayBoundary) {
        // A new calendar day always starts with today's diary, not the date
        // the user was viewing before the app went into the background.
        await home.showTodayForNewScan();
      } else {
        // Also refresh same-day resumes so a scan completed on another route
        // or server-side changes are reflected when the app is reopened.
        await home.loadToday(forceRefresh: true);
      }
    } finally {
      _resumeRefreshInFlight = false;
    }
  }

  void _openCompletedScan() {
    final task = _scanTasks?.completedTask;
    final resultId = task?.resultId;
    if (!mounted || task == null || resultId == null) return;
    final expEarned = task.expEarned;
    _scanTasks!.consumeCompleted(task.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshUser();
      context.read<HomeProvider>().loadToday(forceRefresh: true);
      context.push('/result/$resultId');
      // Keep the reward pending while Result is on screen. MainShell will
      // consume it only after the user returns to Home.
      if (expEarned > 0) {
        context.read<GamificationProvider>().registerScanReward(expEarned);
        unawaited(context.read<GamificationProvider>().refresh());
      }
      unawaited(context.read<GamificationProvider>().refreshRecap());
    });
  }

  void _showPendingRewardWhenHomeIsVisible(String location) {
    if (location != '/home') {
      _rewardDisplayScheduled = false;
      return;
    }
    if (_rewardDisplayScheduled) return;
    _rewardDisplayScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rewardDisplayScheduled = false;
      if (!mounted || GoRouterState.of(context).matchedLocation != '/home') {
        return;
      }
      final exp = context.read<GamificationProvider>().takePendingScanReward();
      if (exp <= 0) return;
      showExpGainPrompt(
        context,
        exp: exp,
        reason: 'Quét món ăn',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;
    _showPendingRewardWhenHomeIsVisible(location);

    int currentIndex;
    switch (location) {
      case '/home':
        currentIndex = 0;
      case '/history':
        currentIndex = 1;
      case '/stats':
        currentIndex = 2;
      case '/profile':
        currentIndex = 3;
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
                    context.go('/stats');
                  case 3:
                    context.go('/profile');
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_filled),
                  label: s.tabHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.history_rounded),
                  label: s.historyTitle,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: s.statistics,
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
