import 'package:calgo/l10n/generated/app_localizations.dart';
import 'package:calgo/models/user.dart';
import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/providers/auth_provider.dart';
import 'package:calgo/providers/home_provider.dart';
import 'package:calgo/providers/onboarding_provider.dart';
import 'package:calgo/providers/payment_provider.dart';
import 'package:calgo/screens/onboarding/steps/premium_paywall_step.dart';
import 'package:calgo/screens/onboarding/steps/spin_wheel_dialog.dart';
import 'package:calgo/services/api_service.dart';
import 'package:calgo/services/analytics_service.dart';
import 'package:calgo/services/exercise_service.dart';
import 'package:calgo/services/home_service.dart';
import 'package:calgo/services/meal_guidance_service.dart';
import 'package:calgo/widgets/app_rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_language': 'en',
    });
  });

  Widget createTestWidget(Widget child, [PaymentProvider? paymentProvider]) {
    final api = ApiService();
    final analytics = AnalyticsService(api);
    final settings = AppSettingsProvider();
    final onboarding = OnboardingProvider(analyticsService: analytics);
    final auth = AuthProvider(api)
      ..updateUser(
        User(
          id: 'test-user',
          name: 'Test User',
          hasCompletedOnboarding: true,
        ),
      );
    final home = HomeProvider(
      HomeService(api),
      MealGuidanceService(api),
      ExerciseService(api),
    );
    final payment = paymentProvider ??
        PaymentProvider(
          api,
          accountIdProvider: () => auth.user?.id,
        );

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        Provider<AnalyticsService>.value(value: analytics),
        ChangeNotifierProvider<AppSettingsProvider>.value(value: settings),
        ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<HomeProvider>.value(value: home),
        ChangeNotifierProvider<PaymentProvider>.value(value: payment),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('AppRatingDialog renders 5 stars and allows selection and dismiss', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppRatingDialog.show(context),
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog elements exist
    expect(find.byType(AppRatingDialog), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(6)); // 1 big header badge + 5 stars

    // Tap on Not Now / later button
    final notNowFinder = find.text('Not now');
    expect(notNowFinder, findsOneWidget);
    await tester.tap(notNowFinder);
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.byType(AppRatingDialog), findsNothing);
  });

  testWidgets('In-app paywall (onboardingMode: false) shows close button immediately and exits without spinner', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => const PremiumPaywallStep(
                      onboardingMode: false,
                    ),
                  ),
                ),
                child: const Text('Open Paywall'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open paywall
    await tester.tap(find.text('Open Paywall'));
    await tester.pumpAndSettle();

    // Verify paywall is shown
    expect(find.byType(PremiumPaywallStep), findsOneWidget);

    // Close button should be present immediately
    final closeBtn = find.byIcon(Icons.close_rounded);
    expect(closeBtn, findsOneWidget);

    // Tap close button
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    // PremiumPaywallStep popped
    expect(find.byType(PremiumPaywallStep), findsNothing);

    // SpinWheelDialog should NOT be displayed
    expect(find.byType(SpinWheelDialog), findsNothing);
  });

  testWidgets('Paywall displays monthly breakdown for year plan', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const PremiumPaywallStep(
          onboardingMode: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Year plan should show month price unit
    expect(find.textContaining(RegExp(r'month', caseSensitive: false)), findsWidgets);
    expect(find.textContaining(RegExp(r'year', caseSensitive: false)), findsWidgets);
  });
}
