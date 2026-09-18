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
          // Already signed in: go straight to home
          if (auth.isAuthenticated) {
            return '/home';
          }
          // Not signed in + onboarding already completed before (token expired):
          // send to standalone login so they can sign back in quickly.
          if (onboarding.isCompleted) return '/login';
          // Brand-new user: start the full onboarding flow (welcome → questions
          // → AccountStep for sign-in at the very end).
          return '/onboarding';
        }

        final onOnboarding = state.matchedLocation == '/onboarding';
        final onLogin = state.matchedLocation == '/login';

        if (auth.loading) return null;

        // When user is authenticated, they should be able to access the app (/home)
        // Never trap an authenticated user on onboarding or login.
        if (auth.isAuthenticated) {
          if (onLogin || (onOnboarding && !onboarding.isTestingOnboarding && !onboarding.isRecalculating)) {
            return '/home';
          }
          return null;
        }

        // Unauthenticated users may only be on /onboarding or /login.
        // /onboarding contains the AccountStep so they sign in there.
        // Only redirect to /login when onboarding is already marked done
        // (token-expired scenario).
        final done = onboarding.isCompleted;
        if (!onOnboarding && !onLogin) {
          return done ? '/login' : '/onboarding';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _mascotController;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F6),
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _mascotController,
            child: Image.asset(
              'assets/images/apple_mascot/apple_hello.png',
              height: 340,
              fit: BoxFit.contain,
            ),
            builder: (context, child) {
              final t = reduceMotion ? 0.5 : _mascotController.value;
              return Transform.translate(
                offset: Offset(0, -4 * math.sin(t * math.pi)),
                child: Transform.rotate(
                  angle: 0.035 * math.sin((t - .5) * math.pi),
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
