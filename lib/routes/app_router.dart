import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_build_config.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/meal_guidance/meal_guidance_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/scan/barcode_scan_screen.dart';
import '../screens/pricing/pricing_screen.dart';
import '../screens/onboarding/steps/premium_paywall_step.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/recap/daily_recap_screen.dart';
import '../widgets/main_shell.dart';
import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';

/// Route guards use the one-time in-memory onboarding state. Reading storage
/// inside redirect previously delayed every tab and screen transition.
GoRouter createAppRouter(OnboardingProvider onboarding, AuthProvider auth) =>
    GoRouter(
      initialLocation: '/startup',
      refreshListenable: Listenable.merge([onboarding, auth]),
      redirect: (context, state) {
        final onStartup = state.matchedLocation == '/startup';
        if (!onboarding.initialized) {
          return onStartup ? null : '/startup';
        }
        if (onStartup) {
          if (auth.loading) return null;
          // Already signed in: go home or resume onboarding.
          if (auth.isAuthenticated) {
            return auth.user!.hasCompletedOnboarding ? '/home' : '/onboarding';
          }
          // Not signed in + onboarding already completed before (token expired):
          // send to standalone login so they can sign back in quickly.
          if (onboarding.isCompleted) return '/login';
          // Brand-new user: start the full onboarding flow (welcome → questions
          // → AccountStep for sign-in at the very end).
          return '/onboarding';
        }

        // The server profile is the source of truth per account. A single
        // device-level onboarding flag must never make a newly signed-in user
        // inherit the previous user's completed profile.
        final done = onboarding.isTestingOnboarding
            ? false
            : auth.isAuthenticated
                ? auth.user!.hasCompletedOnboarding
                : onboarding.isCompleted;
        final onOnboarding = state.matchedLocation == '/onboarding';
        final onLogin = state.matchedLocation == '/login';

        if (auth.loading) return null;

        // Unauthenticated users may only be on /onboarding or /login.
        // /onboarding contains the AccountStep so they sign in there.
        // Only redirect to /login when onboarding is already marked done
        // (token-expired scenario).
        if (!auth.isAuthenticated && !onOnboarding && !onLogin) {
          return done ? '/login' : '/onboarding';
        }

        if (!done && !onOnboarding && !onLogin) {
          return '/onboarding';
        }
        if (done && onOnboarding) {
          return auth.isAuthenticated ? '/home' : '/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/startup',
          builder: (context, state) => const _StartupScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/scan',
          builder: (context, state) => const ScanScreen(),
        ),
        GoRoute(
          path: '/barcode-scan',
          builder: (context, state) => const BarcodeScanScreen(),
        ),
        GoRoute(
          path: '/pricing',
          builder: (context, state) => const PricingScreen(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const PhotoGalleryScreen(),
        ),
        // Result is a full-screen detail page. Keep it outside the Home
        // Shell so opening a saved photo from Gallery does not rebuild the
        // shell and fall back to the Home tab.
        GoRoute(
          path: '/result/:id',
          builder: (context, state) => ResultScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/meal-guidance',
          builder: (context, state) => const MealGuidanceScreen(),
        ),
        if (!AppBuildConfig.isTesting)
          GoRoute(
            path: '/premium',
            builder: (context, state) => PremiumPaywallStep(
              onboardingMode: false,
              source: state.uri.queryParameters['source'] ?? 'profile',
            ),
          ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
            GoRoute(
              path: '/recap',
              builder: (context, state) => const DailyRecapPage(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mascotController;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            children: [
              const Spacer(flex: 4),
              Image.asset(
                'assets/images/calgo_logo_wordmark.png',
                width: 160,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _mascotController,
                child: Image.asset(
                  'assets/images/apple_mascot/apple_hello.png',
                  height: 320,
                  fit: BoxFit.contain,
                ),
                builder: (context, child) {
                  final t = reduceMotion ? 0.5 : _mascotController.value;
                  return Transform.translate(
                    offset: Offset(0, -3 * math.sin(t * math.pi)),
                    child: Transform.rotate(
                      angle: 0.035 * math.sin((t - .5) * math.pi),
                      child: child,
                    ),
                  );
                },
              ),
              const Spacer(flex: 2),
              _StartupProgress(
                controller: _progressController,
                reduceMotion: reduceMotion,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartupProgress extends StatelessWidget {
  final AnimationController controller;
  final bool reduceMotion;

  const _StartupProgress({
    required this.controller,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E8),
          borderRadius: BorderRadius.circular(99),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              const segmentWidth = 72.0;
              final t = reduceMotion ? .28 : controller.value;
              final left =
                  (constraints.maxWidth + segmentWidth) * t - segmentWidth;
              return Stack(children: [
                Positioned(
                  left: left,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF151518),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      );
}
