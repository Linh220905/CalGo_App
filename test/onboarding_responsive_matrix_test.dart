import 'package:calgo/main.dart';
import 'package:calgo/models/user.dart';
import 'package:calgo/providers/app_settings_provider.dart';
import 'package:calgo/providers/auth_provider.dart';
import 'package:calgo/providers/home_provider.dart';
import 'package:calgo/providers/onboarding_provider.dart';
import 'package:calgo/screens/onboarding/steps/account_step.dart';
import 'package:calgo/screens/onboarding/steps/activity_step.dart';
import 'package:calgo/screens/onboarding/steps/age_step.dart';
import 'package:calgo/screens/onboarding/steps/analysis_result_step.dart';
import 'package:calgo/screens/onboarding/steps/avoid_foods_step.dart';
import 'package:calgo/screens/onboarding/steps/budget_step.dart';
import 'package:calgo/screens/onboarding/steps/diet_step.dart';
import 'package:calgo/screens/onboarding/steps/gender_step.dart';
import 'package:calgo/screens/onboarding/steps/goal_specific_step.dart';
import 'package:calgo/screens/onboarding/steps/goal_step.dart';
import 'package:calgo/screens/onboarding/steps/habit_step.dart';
import 'package:calgo/screens/onboarding/steps/height_step.dart';
import 'package:calgo/screens/onboarding/steps/hero_step.dart';
import 'package:calgo/screens/onboarding/steps/home_step.dart';
import 'package:calgo/screens/onboarding/steps/name_step.dart';
import 'package:calgo/screens/onboarding/steps/nutrition_priority_step.dart';
import 'package:calgo/screens/onboarding/steps/pace_step.dart';
import 'package:calgo/screens/onboarding/steps/prep_time_step.dart';
import 'package:calgo/screens/onboarding/steps/referral_step.dart';
import 'package:calgo/screens/onboarding/steps/social_proof_step.dart';
import 'package:calgo/screens/onboarding/steps/splash_step.dart';
import 'package:calgo/screens/onboarding/steps/target_weight_step.dart';
import 'package:calgo/screens/onboarding/steps/weight_step.dart';
import 'package:calgo/services/api_service.dart';
import 'package:calgo/services/exercise_service.dart';
import 'package:calgo/services/home_service.dart';
import 'package:calgo/services/meal_guidance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final steps = <({String name, Widget widget})>[
    (name: 'splash', widget: const SplashStep()),
    (name: 'welcome', widget: const HeroStep()),
    (name: 'goal', widget: const GoalStep()),
    (name: 'goal specific', widget: const GoalSpecificStep()),
    (name: 'name', widget: const NameStep()),
    (name: 'gender', widget: const GenderStep()),
    (name: 'age', widget: const AgeStep()),
    (name: 'height', widget: const HeightStep()),
    (name: 'weight', widget: const WeightStep()),
    (name: 'target weight', widget: const TargetWeightStep()),
    (name: 'pace', widget: const PaceStep()),
    (name: 'activity', widget: const ActivityStep()),
    (name: 'diet', widget: const DietStep()),
    (name: 'prep time', widget: const PrepTimeStep()),
    (name: 'budget', widget: const BudgetStep()),
    (name: 'nutrition priority', widget: const NutritionPriorityStep()),
    (name: 'avoid foods', widget: const AvoidFoodsStep()),
    (name: 'referral', widget: const ReferralStep()),
    (name: 'habit', widget: const HabitStep()),
    (name: 'analysis', widget: const AnalysisResultStep()),
    (name: 'social proof', widget: const SocialProofStep()),
    (name: 'account', widget: const AccountStep()),
    (name: 'first scan', widget: const HomeStep()),
  ];

  for (final step in steps) {
    testWidgets(
      '${step.name} has no overflow on a 320x568 phone with large system text',
      (tester) async {
        await _pumpStep(tester, step.widget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('name step remains usable above the keyboard', (tester) async {
    await _pumpStep(
      tester,
      const NameStep(),
      viewInsets: const FakeViewPadding(bottom: 280),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpStep(
  WidgetTester tester,
  Widget step, {
  FakeViewPadding viewInsets = FakeViewPadding.zero,
}) async {
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  tester.view
    ..physicalSize = const Size(320, 568)
    ..devicePixelRatio = 1
    ..padding = const FakeViewPadding(top: 24, bottom: 24)
    ..viewInsets = viewInsets;
  tester.platformDispatcher.textScaleFactorTestValue = 1.6;

  SharedPreferences.setMockInitialValues({
    'app_language': 'en',
    'app_theme_mode': false,
  });

  final api = ApiService();
  final settings = AppSettingsProvider();
  final onboarding = OnboardingProvider();
  onboarding.data
    ..name = 'Responsive Test User'
    ..applyDisplayedDefaults();
  final auth = AuthProvider(api)
    ..updateUser(
      User(
        id: 'responsive-test-user',
        name: 'Responsive Test User',
        hasCompletedOnboarding: true,
      ),
    );
  final home = HomeProvider(
    HomeService(api),
    MealGuidanceService(api),
    ExerciseService(api),
  );
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, __) => step)],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: home),
      ],
      child: CalGoApp(router: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}
