import 'dart:convert';
import 'dart:io';

import 'package:calgo/l10n/generated/app_localizations.dart';
import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/utils/stats_localization.dart';
import 'package:calgo/utils/weight_forecast.dart';
import 'package:calgo/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'German translates every template message and preserves placeholders',
    () {
      final english =
          jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
              as Map<String, dynamic>;
      final german =
          jsonDecode(File('lib/l10n/app_de.arb').readAsStringSync())
              as Map<String, dynamic>;
      expect(german.keys.toSet(), english.keys.toSet());
      for (final key in english.keys.where((key) => !key.startsWith('@'))) {
        expect((german[key] as String).trim(), isNotEmpty, reason: key);
        final metadata = english['@$key'] as Map<String, dynamic>?;
        final placeholders = metadata?['placeholders'] as Map<String, dynamic>?;
        for (final name in placeholders?.keys ?? <String>[]) {
          // A locale may omit a placeholder that exists only in another locale.
          if (!key.startsWith('stats') &&
              (english[key] as String).contains('{$name')) {
            expect(german[key], contains('{$name'), reason: '$key: $name');
          }
        }
      }
      final de = lookupAppLocalizations(const Locale('de'));
      expect(de.languageDisplayName, 'Deutsch');
      expect(de.mealCount(0), 'Keine Mahlzeiten');
      expect(de.mealCount(1), '1 Mahlzeit');
      expect(de.mealCount(3), '3 Mahlzeiten');
      expect(de.goalLoseDiffText('5'), 'Ziel: 5 kg abnehmen');
    },
  );

  testWidgets('German follows device locale and persists a selected language', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'de',
      'DE',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettingsProvider();
    addTearDown(settings.dispose);
    await tester.pump();
    expect(settings.languageCode, 'de');
    expect(settings.strings.languageDisplayName, 'Deutsch');

    await settings.setLanguage('en');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: Consumer<AppSettingsProvider>(
          builder: (_, value, child) => MaterialApp(
            locale: value.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LanguageSelectorButton()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LanguageSelectorButton));
    await tester.pumpAndSettle();
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('🇩🇪'), findsOneWidget);
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(settings.languageCode, 'de');
    expect(
      (await SharedPreferences.getInstance()).getString('app_language'),
      'de',
    );
    final reloaded = AppSettingsProvider();
    addTearDown(reloaded.dispose);
    await tester.pump();
    expect(reloaded.languageCode, 'de');
  });

  testWidgets('German covers stats, forecasts, dates and meal guidance', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(StatsLocalization.levelTitle(context, 1), 'Anfänger');
    expect(
      StatsLocalization.bmiCategory(context, 'normal', ''),
      'Normalgewicht',
    );
    expect(
      StatsLocalization.achievementName(context, 'first_scan', ''),
      'Glänzender Start',
    );
    expect(StatsLocalization.periodLabel(context, 7), '7 Tage');
    expect(
      StatsLocalization.weekdayShort(context, DateTime(2026, 11, 17)),
      'Di',
    );
    expect(StatsLocalization.monthShort(context, DateTime(2026, 3, 1)), 'Mär');
    expect(
      StatsLocalization.forecastOnTrackBody(
        context,
        calories: 1800,
        target: '65',
        weeks: '10 Wochen',
      ),
      contains('65 kg'),
    );
    expect(
      StatsLocalization.mealGuidanceStatusTag(context, 'Đang đi đúng hướng'),
      'Auf Kurs',
    );
    expect(
      StatsLocalization.mealGuidanceDishAdjustment(
        context,
        'Để sốt riêng',
      ),
      isNotEmpty,
    );
    for (final status in WeightForecastStatus.values) {
      final forecast = WeightForecast(
        status: status,
        goal: 'lose',
        currentWeight: 75,
        targetWeight: 65,
        calories: 1800,
        maintenanceCalories: 2300,
        weeklyWeightChangeKg: -0.5,
        estimatedWeeks: 20,
      );
      expect(
        StatsLocalization.forecastStatusTitle(context, forecast),
        isNotEmpty,
      );
      expect(
        StatsLocalization.forecastStatusBody(
          context,
          forecast,
          periodLabel: 'heute',
          weeksLabel: '20 Wochen',
          recommendedCalories: 1800,
        ),
        isNotEmpty,
      );
    }
  });
}
