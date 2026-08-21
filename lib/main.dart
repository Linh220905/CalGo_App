import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/onboarding_service.dart';
import 'services/home_service.dart';
import 'services/scan_service.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';
import 'services/meal_guidance_service.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/home_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/scan_task_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final apiService = ApiService();
  final analyticsService = AnalyticsService(apiService);
  final onboardingProvider = OnboardingProvider(
    onboardingService: OnboardingService(apiService),
    analyticsService: analyticsService,
  );
  final authProvider = AuthProvider(apiService);
  // Wire the silent-refresh interceptor. Any 401 from any service will trigger
  // a background token rotation + retry without user interaction.
  apiService.refreshCallback = authProvider.refreshTokenSilently;
  final paymentProvider = PaymentProvider(apiService);
  paymentProvider.setCreditsVerifiedCallback(authProvider.refreshUser);
  var restoredPaymentAuthScope = -1;
  var trackedFirstOpenAuthScope = -1;
  authProvider.addListener(() {
    if (authProvider.isAuthenticated &&
        apiService.authScope != trackedFirstOpenAuthScope) {
      trackedFirstOpenAuthScope = apiService.authScope;
      unawaited(analyticsService.trackAppFirstOpen());
      unawaited(analyticsService.flushPending());
    }
    // queryPurchases/restore is needed after a cold start and after account
    // switching so a renewed subscription refreshes the server entitlement.
    if (authProvider.isAuthenticated &&
        apiService.authScope != restoredPaymentAuthScope) {
      restoredPaymentAuthScope = apiService.authScope;
      unawaited(paymentProvider.restorePurchases());
      // BUG 4 fix: retry any purchase whose server-side verification failed
      // in a previous session due to an expired auth token.
      unawaited(paymentProvider.retryPendingPurchaseVerification());
    }
  });
  // Start both bootstrap reads before the router is built. The router shows a
  // neutral startup screen until they finish, never a persisted onboarding step.
  unawaited(onboardingProvider.init());
  unawaited(authProvider.tryRestore());

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<AnalyticsService>.value(value: analyticsService),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => authProvider,
        ),
        ChangeNotifierProvider.value(value: onboardingProvider),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            HomeService(apiService),
            MealGuidanceService(apiService),
          ),
        ),
        ChangeNotifierProvider<PaymentProvider>.value(value: paymentProvider),
        Provider(create: (_) => ScanService(apiService)),
        ChangeNotifierProvider(
          create: (context) => ScanTaskProvider(context.read<ScanService>()),
        ),
      ],
      child:
          CalGoApp(router: createAppRouter(onboardingProvider, authProvider)),
    ),
  );

  // Timezone data for scheduled notifications is expensive to deserialize.
  // Starting it before runApp blocked Flutter's first frame and exposed the
  // plain Android launch background for several seconds.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(NotificationService.instance.init());
  });
}

class CalGoApp extends StatelessWidget {
  final RouterConfig<Object> router;

  const CalGoApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp.router(
          title: 'CalGo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.2,
            child: child ?? const SizedBox.shrink(),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
