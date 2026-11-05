import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:calgo/models/home_data.dart';
import 'package:calgo/models/user.dart';
import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/providers/auth_provider.dart';
import 'package:calgo/services/api_service.dart';
import 'package:calgo/screens/home/widgets/nutrition_swipe_section.dart';
import 'package:calgo/screens/home/widgets/cal_ai_hero_card.dart';
import 'package:calgo/screens/home/widgets/cal_ai_macro_card.dart';
import 'package:calgo/screens/home/widgets/micro_nutrients_page.dart';
import 'package:calgo/screens/home/widgets/body_vitality_page.dart';
import 'package:calgo/screens/home/widgets/vitality_detail_sheet.dart';
import 'package:calgo/l10n/generated/app_localizations.dart';
import 'package:calgo/widgets/calculation_sources.dart';

Widget _buildTestApp({required Widget child, required bool isPremium}) {
  final user = User(
    id: 'test_user',
    subscriptionTier: isPremium ? 'premium_annual' : null,
    isDev: isPremium,
  );
  final authProvider = AuthProvider(ApiService())..updateUserForTest(user);
  final settingsProvider = AppSettingsProvider();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: settingsProvider,
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final testSummary = TodaySummary(
    consumedCalories: 1500,
    burnedCalories: 200,
    targetCalories: 2000,
    proteinG: 100,
    targetProteinG: 130,
    carbG: 180,
    targetCarbG: 220,
    fatG: 45,
    targetFatG: 60,
    fiberG: 22,
    targetFiberG: 38,
    sugarG: 20,
    targetSugarG: 50,
    sodiumMg: 1200,
    targetSodiumMg: 2000,
    healthScore: 8.5,
    energyVitality: 84.0,
    satietyVitality: 8.3,
    recoveryVitality: 72.0,
    fluidBalanceVitality: 88.0,
  );

  testWidgets('NutritionSwipeSection renders Page 1 by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: SingleChildScrollView(
          child: NutritionSwipeSection(summary: testSummary),
        ),
        isPremium: true,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Calories Left & Macros rendered
    expect(find.text('700'), findsOneWidget); // 2000 + 200 - 1500 = 700
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Home keeps calorie and macro cards close without sources', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: SingleChildScrollView(
          child: NutritionSwipeSection(summary: testSummary),
        ),
        isPremium: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CalculationSources), findsNothing);
    final hero = tester.getRect(find.byType(CalAiHeroCard));
    final macros = tester.getRect(find.byType(CalAiMacroCard).first);
    expect(macros.top - hero.bottom, closeTo(10, 0.1));
  });

  testWidgets('second and third nutrition pages fit the same carousel', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_buildTestApp(
      child: SingleChildScrollView(
        child: NutritionSwipeSection(summary: testSummary),
      ),
      isPremium: true,
    ));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    final microCards = tester.getRect(find.byType(CalAiMacroCard).first);
    final healthCard = tester.getRect(find.ancestor(
      of: find.text('Health Score'),
      matching: find.byType(InkWell),
    ).first);
    expect(healthCard.top - microCards.bottom, closeTo(12, 0.1));
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.byType(BodyVitalityPage), findsOneWidget);
    expect(tester.getSize(find.byType(BodyVitalityPage)).height,
        tester.getSize(find.byType(PageView)).height);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every calculation source type has a tappable link', (
    tester,
  ) async {
    final launched = <String>[];
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'launch') {
            launched.add((call.arguments as Map)['url'] as String);
            return true;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    for (final type in CalculationSourceType.values) {
      await tester.pumpWidget(
        _buildTestApp(
          child: Scaffold(body: CalculationSources(type: type)),
          isPremium: false,
        ),
      );
      await tester.pumpAndSettle();
      final links = find.descendant(
        of: find.byType(CalculationSources),
        matching: find.byType(InkWell),
      );
      expect(links, findsAtLeastNWidgets(1));
      final before = launched.length;
      await tester.tap(links.at(1));
      await tester.pump();
      expect(launched.length, before + 1, reason: '$type link did not open');
      expect(launched.last, startsWith('https://'));
    }
  });

  testWidgets('long vitality sheet stays scrollable on a small screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _buildTestApp(
        child: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => VitalityDetailSheet.show(
                context,
                VitalityDetailData(
                  key: 'test',
                  title: 'Nutrition detail',
                  score: '8/10',
                  description: 'Estimated nutrient values.',
                  source: 'WHO — healthy diet',
                  sourceUrl: 'https://www.who.int/health-topics/healthy-diet',
                  items: List.generate(
                    12,
                    (i) => MapEntry('Nutrient $i', '${i}g'),
                  ),
                ),
              ),
              child: const Text('Open detail'),
            ),
          ),
        ),
        isPremium: true,
      ),
    );
    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Nutrition detail'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'MicroNutrientsPage displays blurred placeholders for Free user',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: SingleChildScrollView(
            child: MicroNutrientsPage(
              summary: testSummary,
              isPremium: false,
              onLockedTap: () {},
            ),
          ),
          isPremium: false,
        ),
      );
      await tester.pumpAndSettle();

      // Free tier: should show --g / -- / 10 blurred placeholders
      expect(find.text('-- / 10'), findsOneWidget);
      expect(find.text('--g'), findsNWidgets(2)); // Fiber & Sugar
      expect(find.text('--mg'), findsOneWidget); // Sodium
    },
  );

  testWidgets(
    'MicroNutrientsPage displays real calculated data for Premium user',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: SingleChildScrollView(
            child: MicroNutrientsPage(summary: testSummary, isPremium: true),
          ),
          isPremium: true,
        ),
      );
      await tester.pumpAndSettle();

      // Premium tier: should show live numbers
      expect(find.text('8.5 / 10'), findsOneWidget);
      expect(find.text('16g'), findsOneWidget); // 38 - 22 = 16g fiber left
      expect(find.text('30g'), findsOneWidget); // 50 - 20 = 30g sugar left
      expect(
        find.text('800mg'),
        findsOneWidget,
      ); // 2000 - 1200 = 800mg sodium left
    },
  );

  testWidgets(
    'BodyVitalityPage displays blurred text for Free user and live stats for Premium',
    (tester) async {
      // Free Mode
      await tester.pumpWidget(
        _buildTestApp(
          child: SingleChildScrollView(
            child: BodyVitalityPage(
              summary: testSummary,
              isPremium: false,
              onLockedTap: () {},
            ),
          ),
          isPremium: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('-- / --'), findsNWidgets(4));

      // Premium Mode
      await tester.pumpWidget(
        _buildTestApp(
          child: SingleChildScrollView(
            child: BodyVitalityPage(summary: testSummary, isPremium: true),
          ),
          isPremium: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('84%'), findsOneWidget);
      expect(find.text('8.3/10'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
    },
  );

  testWidgets(
    'VitalityDetailSheet modal displays scientific source citations',
    (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: VitalityDetailSheet(
            data: const VitalityDetailData(
              key: 'energy',
              title: 'Mức độ ổn định năng lượng',
              score: '84%',
              description: 'Tính theo tỷ lệ Carbs phức hợp vs Đường tự do.',
              source: 'Nguồn: Hướng dẫn Đường tự do của WHO',
              items: [
                MapEntry('Carbs phức hợp', '82%'),
                MapEntry('Đường đơn', '15g'),
              ],
            ),
          ),
          isPremium: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mức độ ổn định năng lượng'), findsOneWidget);
      expect(find.text('84%'), findsOneWidget);
      expect(find.text('Nguồn: Hướng dẫn Đường tự do của WHO'), findsOneWidget);
      expect(find.text('Carbs phức hợp'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
    },
  );
}
