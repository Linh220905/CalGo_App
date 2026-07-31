import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/onboarding_service.dart';
import 'services/home_service.dart';
import 'services/scan_service.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/home_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/payment_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final apiService = ApiService();
  final onboardingProvider = OnboardingProvider(
    onboardingService: OnboardingService(apiService),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService)..tryRestore(),
        ),
        ChangeNotifierProvider.value(value: onboardingProvider),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(HomeService(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(apiService),
        ),
        Provider(create: (_) => ScanService(apiService)),
      ],
      child: CalGoApp(router: createAppRouter(onboardingProvider)),
    ),
  );
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
          routerConfig: router,
        );
      },
    );
  }
}
