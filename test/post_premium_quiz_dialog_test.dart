import 'package:calgo/models/onboarding_data.dart';
import 'package:calgo/providers/onboarding_provider.dart';
import 'package:calgo/screens/onboarding/steps/post_premium_quiz_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('muscle goal defaults to lean high-protein personalization',
      (tester) async {
    await _pumpQuiz(tester, GoalType.gain);

    await _advanceToGoalQuestion(tester);

    expect(find.text('Nhiều protein, ít fat'), findsOneWidget);
    expect(find.textContaining('không đội mỡ'), findsOneWidget);
  });

  testWidgets('lose goal receives calorie-deficit priorities', (tester) async {
    await _pumpQuiz(tester, GoalType.lose);

    await _advanceToGoalQuestion(tester);

    expect(find.text('No lâu, ít calo'), findsOneWidget);
    expect(find.text('Khớp calo còn lại'), findsOneWidget);
  });

  testWidgets('maintain goal receives balanced priorities', (tester) async {
    await _pumpQuiz(tester, GoalType.maintain);

    await _advanceToGoalQuestion(tester);

    expect(find.text('Cân bằng macro'), findsOneWidget);
    expect(find.text('Giữ cân ổn định'), findsOneWidget);
  });

  test('premium personalization completion is scoped to the account', () async {
    SharedPreferences.setMockInitialValues({});
    final onboarding = OnboardingProvider();
    const answers = {
      'meal_pattern': 'three_meals',
      'variety_preference': 'rotate_daily',
      'assistant_priority': 'balanced_macros',
      'setup_version': 1,
    };

    expect(
      await onboarding.hasPremiumCustomization(accountId: 'account-a'),
      isFalse,
    );
    await onboarding.saveMealCustomization(answers, accountId: 'account-a');
    expect(
      await onboarding.hasPremiumCustomization(accountId: 'account-a'),
      isTrue,
    );
    expect(
      await onboarding.hasPremiumCustomization(accountId: 'account-b'),
      isFalse,
    );
  });
}

Future<void> _pumpQuiz(WidgetTester tester, GoalType goal) async {
  final onboarding = OnboardingProvider()..data.goalType = goal;
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: onboarding,
      child: MaterialApp(
        home: Scaffold(
          body: PostPremiumQuizDialog(onCompleted: () async {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _advanceToGoalQuestion(WidgetTester tester) async {
  for (var index = 0; index < 2; index++) {
    final button = find.text('Tiếp tục');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }
}
