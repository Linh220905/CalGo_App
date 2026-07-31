import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/step_progress_bar.dart';
import 'steps/splash_step.dart';
import 'steps/hero_step.dart';
import 'steps/demo_step.dart';
import 'steps/pain_step.dart';
import 'steps/goal_step.dart';
import 'steps/name_step.dart';
import 'steps/gender_step.dart';
import 'steps/age_step.dart';
import 'steps/height_step.dart';
import 'steps/weight_step.dart';
import 'steps/target_weight_step.dart';
import 'steps/target_duration_step.dart';
import 'steps/pace_step.dart';
import 'steps/activity_step.dart';
import 'steps/sports_step.dart';
import 'steps/diet_step.dart';
import 'steps/referral_step.dart';
import 'steps/motivation_step.dart';
import 'steps/habit_step.dart';
import 'steps/biggest_challenge_step.dart';
import 'steps/analysis_result_step.dart';
import 'steps/social_proof_step.dart';
import 'steps/review_request_step.dart';
import 'steps/premium_paywall_step.dart';
import 'steps/account_step.dart';
import 'steps/home_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/home');
            }
          });
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  if (provider.currentStep >= 3 && provider.currentStep <= 19)
                    StepProgressBar(
                      value: (provider.currentStep - 2) / 17,
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStep(provider.currentStep,
                          key: ValueKey(provider.currentStep)),
                    ),
                  ),
                ],
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
        return DemoStep(key: key);
      case 3:
        return PainStep(key: key);
      case 4:
        return GoalStep(key: key);
      case 5:
        return NameStep(key: key);
      case 6:
        return GenderStep(key: key);
      case 7:
        return AgeStep(key: key);
      case 8:
        return HeightStep(key: key);
      case 9:
        return WeightStep(key: key);
      case 10:
        return TargetWeightStep(key: key);
      case 11:
        return TargetDurationStep(key: key);
      case 12:
        return PaceStep(key: key);
      case 13:
        return ActivityStep(key: key);
      case 14:
        return SportsStep(key: key);
      case 15:
        return DietStep(key: key);
      case 16:
        return ReferralStep(key: key);
      case 17:
        return MotivationStep(key: key);
      case 18:
        return HabitStep(key: key);
      case 19:
        return BiggestChallengeStep(key: key);
      case 20:
        return AnalysisResultStep(key: key);
      case 21:
        return SocialProofStep(key: key);
      case 22:
        return ReviewRequestStep(key: key);
      case 23:
        return PremiumPaywallStep(key: key);
      case 24:
        return AccountStep(key: key);
      case 25:
        return HomeStep(key: key);
      default:
        return SizedBox.shrink(key: key);
    }
  }
}
