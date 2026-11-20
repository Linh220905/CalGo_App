import 'dart:io';

import 'package:calgo/l10n/generated/app_localizations.dart';
import 'package:calgo/models/what_to_eat_dish.dart';
import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/screens/home/widgets/what_to_eat_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_language': 'vi'});
  });

  test('WhatToEatDish has 30 dishes, matching names, existing assets, and localized tags', () {
    expect(WhatToEatDish.allDishes.length, 30);
    expect(WhatToEatDish.getDishesFor(MealTimeCategory.breakfast).length, 10);
    expect(WhatToEatDish.getDishesFor(MealTimeCategory.lunch).length, 10);
    expect(WhatToEatDish.getDishesFor(MealTimeCategory.dinner).length, 10);

    final byId = {for (final d in WhatToEatDish.allDishes) d.id: d};
    expect(byId['xoi_xeo_ga']!.name, 'Xôi xéo hành phi');
    expect(byId['com_nieu_ca_kho']!.name, 'Cơm niêu cá kho tộ');
    expect(byId['com_suon_rim']!.name, 'Cơm sườn rim mặn ngọt');

    final vi = lookupAppLocalizations(const Locale('vi'));
    final en = lookupAppLocalizations(const Locale('en'));

    for (final dish in WhatToEatDish.allDishes) {
      expect(File(dish.localAsset).existsSync(), isTrue,
          reason: 'Missing asset file: ${dish.localAsset}');
      expect(dish.localizedTag(vi).isNotEmpty, isTrue);
      expect(dish.localizedTag(en).isNotEmpty, isTrue);
      expect(dish.localizedTag(vi), isNot(equals(dish.localizedTag(en))));
    }
  });

  testWidgets(
    'WhatToEatModal renders cleanly on 375x667 iPhone SE, opens popup on tap, and spins twice without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final settings = AppSettingsProvider();
      await settings.setLanguage('vi');

      await tester.pumpWidget(
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: settings,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('vi'),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => WhatToEatModal.show(context, isDark: false),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(WhatToEatModal), findsOneWidget);
      expect(find.text('Hôm nay ăn gì?'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Switch to Lunch tab
      await tester.tap(find.text('Bữa trưa'));
      await tester.pumpAndSettle();
      expect(find.text('Cơm tấm sườn nướng trứng'), findsWidgets);
      expect(tester.takeException(), isNull);

      // Tap a dish card directly to open floating popup dialog
      await tester.tap(find.text('Cơm tấm sườn nướng trứng').first);
      await tester.pumpAndSettle();
      expect(find.text('Gợi ý cho bạn!'), findsOneWidget);
      expect(find.text('Scan món thực tế'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Spin 1 via "Quay lại"
      await tester.tap(find.text('Quay lại'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3200));
      await tester.pumpAndSettle();
      expect(find.text('Gợi ý cho bạn!'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Spin 2 consecutively via "Quay lại"
      await tester.tap(find.text('Quay lại'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3200));
      await tester.pumpAndSettle();
      expect(find.text('Gợi ý cho bạn!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
