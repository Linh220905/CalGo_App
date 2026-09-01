import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_build_config.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/step_progress_bar.dart';
import 'steps/splash_step.dart';
import 'steps/hero_step.dart';
import 'steps/goal_step.dart';
import 'steps/goal_specific_step.dart';
import 'steps/name_step.dart';
import 'steps/gender_step.dart';
import 'steps/age_step.dart';
import 'steps/height_step.dart';
import 'steps/weight_step.dart';
import 'steps/target_weight_step.dart';
import 'steps/pace_step.dart';
import 'steps/activity_step.dart';
import 'steps/diet_step.dart';
import 'steps/habit_step.dart';
import 'steps/prep_time_step.dart';
import 'steps/budget_step.dart';
import 'steps/nutrition_priority_step.dart';
import 'steps/avoid_foods_step.dart';
import 'steps/referral_step.dart';
import 'steps/analysis_result_step.dart';
import 'steps/premium_paywall_step.dart';
import 'steps/account_step.dart';
import 'steps/home_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _resetScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.currentStep >= OnboardingProvider.totalSteps) {
          final user = context.read<AuthProvider>().user;
          if (user == null || !user.hasCompletedOnboarding) {
            if (!_resetScheduled) {
              _resetScheduled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _resetScheduled = false;
                if (mounted) {
                  provider.resetLocalProgressForIncompleteAccount();
                }
              });
            }
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/home');
              }
            });
          }
        }
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.2,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
            ),
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    if (provider.isRecalculating)
                      StepProgressBar(
                        value: provider.recalculateProgress,
                      )
                    else if (provider.currentStep >= 2 && provider.currentStep <= 18)
                      StepProgressBar(
                        value: (provider.currentStep - 1) / 17,
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildStep(
                          provider.currentStep,
                          key: ValueKey(provider.currentStep),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(int step, {Key? key}) {
    switch (step) {
      case 0:
        return SplashStep(key: key);
      case 1:
        return HeroStep(key: key);
      case 2:
        return GoalStep(key: key);
      case 3:
        return GoalSpecificStep(key: key);
      case 4:
        return NameStep(key: key);
      case 5:
        return GenderStep(key: key);
      case 6:
        return AgeStep(key: key);
      case 7:
        return HeightStep(key: key);
      case 8:
        return WeightStep(key: key);
      case 9:
        return TargetWeightStep(key: key);
      case 10:
        return PaceStep(key: key);
      case 11:
        return ActivityStep(key: key);
      case 12:
        return DietStep(key: key);
      case 13:
        return PrepTimeStep(key: key);
      case 14:
        return BudgetStep(key: key);
      case 15:
        return NutritionPriorityStep(key: key);
      case 16:
        return AvoidFoodsStep(key: key);
      case 17:
        return ReferralStep(key: key);
      case 18:
        return HabitStep(key: key);
      case 19:
        return AnalysisResultStep(key: key);
      case 20:
        return AppBuildConfig.isTesting
            ? AccountStep(key: key)
            : PremiumPaywallStep(key: key);
      case 21:
        return AppBuildConfig.isTesting
            ? HomeStep(key: key)
            : AccountStep(key: key);
      case 22:
        return HomeStep(key: key);
      default:
        return SizedBox.shrink(key: key);
    }
  }
}
