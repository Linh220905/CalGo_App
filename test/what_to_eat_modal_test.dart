import 'dart:convert';
import 'dart:io';

import 'package:calgo/l10n/generated/app_localizations.dart';
import 'package:calgo/models/what_to_eat_dish.dart';
import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/screens/home/widgets/what_to_eat_modal.dart';
import 'package:calgo/services/what_to_eat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_language': 'vi'});
    WhatToEatService.instance = WhatToEatService(
      client: MockClient((_) async => http.Response('offline', 503)),
    );
  });

  test(
    'WhatToEatDish uses server URLs (no bundled assets), supports JSON roundtrip, and localizes tags',
    () {
      expect(Directory('assets/images/dishes').existsSync(), isFalse);
      expect(WhatToEatDish.fallbackDishes.length, 30);
      expect(WhatToEatDish.getDishesFor(MealTimeCategory.breakfast).length, 10);
      expect(WhatToEatDish.getDishesFor(MealTimeCategory.lunch).length, 10);
      expect(WhatToEatDish.getDishesFor(MealTimeCategory.dinner).length, 10);

      final byId = {for (final d in WhatToEatDish.fallbackDishes) d.id: d};
      expect(byId['xoi_xeo_ga']!.name, 'Xôi xéo hành phi');
      expect(byId['com_nieu_ca_kho']!.name, 'Cơm niêu cá kho tộ');
      expect(byId['com_suon_rim']!.name, 'Cơm sườn rim mặn ngọt');

      final vi = lookupAppLocalizations(const Locale('vi'));
      final en = lookupAppLocalizations(const Locale('en'));

      for (final dish in WhatToEatDish.fallbackDishes) {
        expect(
          dish.imageUrl,
          startsWith('/api/v1/nutrition/what-to-eat/images/'),
        );
        expect(dish.resolvedImageUrl, startsWith('https://'));
        final roundtrip = WhatToEatDish.fromJson(dish.toJson());
        expect(roundtrip.id, dish.id);
        expect(roundtrip.name, dish.name);
        expect(roundtrip.mealType, dish.mealType);
        expect(roundtrip.tagKey, dish.tagKey);
        expect(roundtrip.imageUrl, dish.imageUrl);
        expect(dish.localizedTag(vi).isNotEmpty, isTrue);
        expect(dish.localizedTag(en).isNotEmpty, isTrue);
        expect(dish.localizedTag(vi), isNot(equals(dish.localizedTag(en))));
      }
    },
  );

  test(
    'WhatToEatService fetches dynamic server catalog, persists cache, and caches dish images on disk',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('calgo_wte_test_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var imageRequests = 0;
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/nutrition/what-to-eat')) {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'version': 2,
                'dishes': [
                  {
                    'id': 'banh_xeo_dynamic',
                    'name': 'Bánh xèo tôm nhảy',
                    'meal_type': 'dinner',
                    'calories': 440,
                    'protein': 24,
                    'carbs': 46,
                    'fat': 18,
                    'tag_key': 'balanced',
                    'emoji': '🥞',
                    'image_url':
                        '/api/v1/nutrition/what-to-eat/images/banh_xeo_dynamic.jpg',
                  },
                ],
              }),
            ),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.url.path.endsWith('/banh_xeo_dynamic.jpg')) {
          imageRequests++;
          return http.Response.bytes(const [0xFF, 0xD8, 0xFF, 0xD9], 200);
        }
        return http.Response('not found', 404);
      });

      final service = WhatToEatService(
        client: client,
        cacheDirectoryProvider: () async => tempDir,
      );

      final dishes = await service.fetchDishes(locale: 'vi', forceRefresh: true);
      expect(dishes.length, 1);
      expect(dishes.first.id, 'banh_xeo_dynamic');
      expect(dishes.first.name, 'Bánh xèo tôm nhảy');

      // Persisted catalog survives a fresh service instance while offline.
      final offlineService = WhatToEatService(
        client: MockClient((_) async => http.Response('err', 500)),
        cacheDirectoryProvider: () async => tempDir,
      );
      final persisted = await offlineService.fetchDishes(
        locale: 'vi',
        forceRefresh: true,
      );
      expect(persisted.length, 1);
      expect(persisted.first.id, 'banh_xeo_dynamic');

      // Disk image caching downloads once and reuses disk file on second call.
      final url = dishes.first.resolvedImageUrl;
      final file1 = await service.loadImageFile(url);
      final file2 = await service.loadImageFile(url);
      expect(file1, isNotNull);
      expect(file2?.path, file1?.path);
      expect(imageRequests, 1);
    },
  );

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
                    onPressed: () =>
                        WhatToEatModal.show(context, isDark: false),
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
