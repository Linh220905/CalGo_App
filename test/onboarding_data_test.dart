import 'package:calgo/models/onboarding_data.dart';
import 'package:calgo/widgets/horizontal_ruler_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingData nutrition calculation', () {
    test('fills the picker defaults and always produces calorie targets', () {
      final data = OnboardingData(
        gender: Gender.male,
        goalType: GoalType.lose,
        activityLevel: ActivityLevel.moderate,
      );

      data.applyDisplayedDefaults();

      expect(data.age, OnboardingData.defaultAge);
      expect(data.heightCm, OnboardingData.defaultHeightCm);
      expect(data.weightKg, OnboardingData.defaultWeightKg);
      expect(data.targetCaloriesPerDay, closeTo(2027, 1));
      expect(data.targetProteinG, greaterThan(0));
      expect(data.targetCarbG, greaterThan(0));
      expect(data.targetFatG, greaterThan(0));
    });

    test('uses the selected activity factor', () {
      OnboardingData profile(ActivityLevel activityLevel) => OnboardingData(
            gender: Gender.female,
            age: 30,
            heightCm: 165,
            weightKg: 60,
            goalType: GoalType.maintain,
            activityLevel: activityLevel,
          );

      expect(
        profile(ActivityLevel.veryActive).targetCaloriesPerDay,
        greaterThan(
          profile(ActivityLevel.sedentary).targetCaloriesPerDay,
        ),
      );
    });

    test('keeps calories and macros safe for aggressive goals', () {
      final data = OnboardingData(
        gender: Gender.female,
        age: 40,
        heightCm: 150,
        weightKg: 150,
        goalType: GoalType.lose,
        activityLevel: ActivityLevel.sedentary,
        lossPerWeekKg: 1.5,
      );

      expect(data.targetCaloriesPerDay, greaterThanOrEqualTo(1200));
      expect(data.targetProteinG, greaterThan(0));
      expect(data.targetCarbG, greaterThanOrEqualTo(0));
      expect(data.targetFatG, greaterThan(0));
    });

    test('maps mobile activity enums to backend values', () {
      final data = OnboardingData();

      data.activityLevel = ActivityLevel.light;
      expect(data.activityApiValue, 'lightly_active');
      data.activityLevel = ActivityLevel.moderate;
      expect(data.activityApiValue, 'moderately_active');
      data.activityLevel = ActivityLevel.active;
      expect(data.activityApiValue, 'very_active');
      data.activityLevel = ActivityLevel.veryActive;
      expect(data.activityApiValue, 'extremely_active');
    });
  });

  group('OnboardingData.hasCompleteNutritionProfile', () {
    test('is false for empty or partially restored drafts', () {
      final data = OnboardingData(
        gender: Gender.male,
        age: 30,
        heightCm: 175,
      );

      expect(data.hasCompleteNutritionProfile, isFalse);
    });

    test('is true when weight-loss target inputs are explicit', () {
      final data = OnboardingData(
        gender: Gender.male,
        age: 30,
        heightCm: 175,
        weightKg: 80,
        goalType: GoalType.lose,
        targetWeightKg: 72,
        lossPerWeekKg: 0.5,
        activityLevel: ActivityLevel.moderate,
      );

      expect(data.hasCompleteNutritionProfile, isTrue);
    });

    test('maintain goal does not require a weekly weight change', () {
      final data = OnboardingData(
        gender: Gender.female,
        age: 28,
        heightCm: 162,
        weightKg: 58,
        goalType: GoalType.maintain,
        targetWeightKg: 58,
        activityLevel: ActivityLevel.light,
      );

      expect(data.hasCompleteNutritionProfile, isTrue);
    });
  });

  testWidgets('ruler persists its visible initial value without scrolling',
      (tester) async {
    double? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: HorizontalRulerPickerCard(
              min: 100,
              max: 220,
              initialValue: 170,
              primaryUnit: 'cm',
              secondaryUnit: 'ft',
              conversionFactor: 0.0328084,
              headerTitle: 'Chiều cao',
              onChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(selectedValue, 170);
  });
}
