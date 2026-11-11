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
import 'package:calgo/services/review_service.dart';
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

  test('ReviewService handles prompt checks, cooldown and rating flags', () async {
    // 1. Initially should prompt
    final canPromptInitial = await ReviewService.shouldPromptReview();
    expect(canPromptInitial, isTrue);

    // 2. After marking rated, should NOT prompt
    await ReviewService.markRated();
    final canPromptAfterRated = await ReviewService.shouldPromptReview();
    expect(canPromptAfterRated, isFalse);

    // 3. Reset and check cooldown
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_rated_app');
    await ReviewService.recordPromptShown();
    final canPromptDuringCooldown = await ReviewService.shouldPromptReview();
    expect(canPromptDuringCooldown, isFalse);
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

    // Year plan should show month price unit and 3 days trial title
    expect(find.textContaining(RegExp(r'month', caseSensitive: false)), findsWidgets);
    expect(find.textContaining(RegExp(r'year', caseSensitive: false)), findsWidgets);
    expect(find.textContaining(RegExp(r'3 days', caseSensitive: false)), findsWidgets);
  });
}
