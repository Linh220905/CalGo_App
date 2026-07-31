import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/pricing/pricing_screen.dart';
import '../screens/gallery/gallery_screen.dart';
import '../widgets/main_shell.dart';
import '../providers/onboarding_provider.dart';

/// Route guards use the one-time in-memory onboarding state. Reading storage
/// inside redirect previously delayed every tab and screen transition.
GoRouter createAppRouter(OnboardingProvider onboarding) => GoRouter(
      initialLocation: '/onboarding',
      refreshListenable: onboarding,
      redirect: (context, state) {
        if (!onboarding.initialized) {
          return state.matchedLocation == '/onboarding' ? null : '/onboarding';
        }
        final done = onboarding.isCompleted;
        final onOnboarding = state.matchedLocation == '/onboarding';
        final onLogin = state.matchedLocation == '/login';

        if (!done && !onOnboarding && !onLogin) {
          return '/onboarding';
        }
        if (done && onOnboarding) {
          return '/home';
        }
        return null;
      },
      routes: [
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
          path: '/pricing',
          builder: (context, state) => const PricingScreen(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const PhotoGalleryScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/result/:id',
              builder: (context, state) => ResultScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );
