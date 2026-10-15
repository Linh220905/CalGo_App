import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calgo/utils/nutrient_svg_icons.dart';
import 'package:calgo/screens/result/result_screen.dart';

void main() {
  group('NutrientSvgIcons Tests', () {
    testWidgets('all 12 vector SVG icons render properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  NutrientSvgIcons.fiber(size: 18, color: Colors.green),
                  NutrientSvgIcons.sugar(size: 18, color: Colors.amber),
                  NutrientSvgIcons.sodium(size: 18, color: Colors.blue),
                  NutrientSvgIcons.calcium(size: 18, color: Colors.indigo),
                  NutrientSvgIcons.iron(size: 18, color: Colors.red),
                  NutrientSvgIcons.potassium(size: 18, color: Colors.purple),
                  NutrientSvgIcons.energy(size: 18, color: Colors.teal),
                  NutrientSvgIcons.satiety(size: 18, color: Colors.teal),
                  NutrientSvgIcons.focus(size: 18, color: Colors.teal),
                  NutrientSvgIcons.lock(size: 20, color: Colors.amber),
                  NutrientSvgIcons.crown(size: 14, color: Colors.white),
                  NutrientSvgIcons.flask(size: 20, color: Colors.blue),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('IngredientItem Micronutrients Parsing', () {
    test('IngredientItem parses all 6 micronutrients correctly', () {
      final json = {
        'ten': 'Phở bò',
        'khoi_luong_gram': 450.0,
        'calo': 480.0,
        'carb': 58.0,
        'protein': 24.0,
        'fat': 12.0,
        'fiber': 4.5,
        'sugar': 3.2,
        'sodium': 650.0,
        'calcium': 120.0,
        'iron': 3.1,
        'potassium': 320.0,
        'don_vi': 'bát',
      };

      final item = IngredientItem.fromJson(json);

      expect(item.ten, 'Phở bò');
      expect(item.khoiLuongGram, 450.0);
      expect(item.calo, 480.0);
      expect(item.carb, 58.0);
      expect(item.protein, 24.0);
      expect(item.fat, 12.0);
      expect(item.fiber, 4.5);
      expect(item.sugar, 3.2);
      expect(item.sodium, 650.0);
      expect(item.calcium, 120.0);
      expect(item.iron, 3.1);
      expect(item.potassium, 320.0);
      expect(item.unit, 'bát');
    });

    test('IngredientItem defaults missing micronutrients to zero', () {
      final json = {
        'ten': 'Cơm trắng',
        'khoi_luong_gram': 150.0,
        'calo': 200.0,
        'carb': 45.0,
        'protein': 4.0,
        'fat': 0.5,
      };

      final item = IngredientItem.fromJson(json);

      expect(item.fiber, 0.0);
      expect(item.sugar, 0.0);
      expect(item.sodium, 0.0);
      expect(item.calcium, 0.0);
      expect(item.iron, 0.0);
      expect(item.potassium, 0.0);
    });
  });
}
