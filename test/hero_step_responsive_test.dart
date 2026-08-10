import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/providers/onboarding_provider.dart';
import 'package:calgo/screens/onboarding/onboarding_screen.dart';
import 'package:calgo/screens/onboarding/steps/hero_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_language': 'en',
      'app_theme_mode': false,
    });
  });

  final scenarios = <({String name, Size size, double textScale})>[
    (
      name: 'small phone',
      size: const Size(320, 568),
      textScale: 1,
    ),
    (
      name: 'short phone with large system text',
      size: const Size(360, 640),
      textScale: 1.6,
    ),
    (
      name: 'regular phone',
      size: const Size(412, 915),
      textScale: 1,
    ),
  ];

  for (final scenario in scenarios) {
    testWidgets('keeps the CTA visible on a ${scenario.name}', (tester) async {
      addTearDown(tester.view.reset);
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );

      tester.view
        ..physicalSize = scenario.size
        ..devicePixelRatio = 1
        ..padding = const FakeViewPadding(top: 24, bottom: 24);
      tester.platformDispatcher.textScaleFactorTestValue = scenario.textScale;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ],
          child: const MaterialApp(home: HeroStep()),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.byKey(const Key('hero_get_started_button'));
      final buttonRect = tester.getRect(button);

      expect(button, findsOneWidget);
      expect(button.hitTestable(), findsOneWidget);
      expect(buttonRect.top, greaterThanOrEqualTo(24));
      expect(buttonRect.bottom, lessThanOrEqualTo(scenario.size.height - 24));
      expect(find.byType(Scrollable), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the onboarding flow caps excessive system text scaling',
      (tester) async {
    addTearDown(tester.view.reset);
    addTearDown(
      tester.platformDispatcher.clearTextScaleFactorTestValue,
    );

    SharedPreferences.setMockInitialValues({
      'app_language': 'en',
      'app_theme_mode': false,
      'onboarding_version': 8,
      'onboarding_step': 1,
    });
    final onboarding = OnboardingProvider();
    await onboarding.init();

    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(top: 24, bottom: 24);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
          ChangeNotifierProvider.value(value: onboarding),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final welcome = find.text('Welcome to');
    final button = find.byKey(const Key('hero_get_started_button'));

    expect(welcome, findsOneWidget);
    expect(
      MediaQuery.textScalerOf(tester.element(welcome)).scale(1),
      1.2,
    );
    expect(button.hitTestable(), findsOneWidget);
    expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(616));
    expect(tester.takeException(), isNull);
  });
}
