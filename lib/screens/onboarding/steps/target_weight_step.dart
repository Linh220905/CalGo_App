import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/horizontal_ruler_picker.dart';

class TargetWeightStep extends StatelessWidget {
  const TargetWeightStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OnboardingProvider>();
    final goal = provider.data.goalType ?? GoalType.maintain;
    final initialCurrent =
        provider.data.weightKg ?? OnboardingData.defaultWeightKg;
    final fallbackTarget = switch (goal) {
      GoalType.lose => initialCurrent - 5,
      GoalType.gain => initialCurrent + 5,
      GoalType.maintain => initialCurrent,
    };
    final initialTarget = (goal == GoalType.maintain
            ? initialCurrent
            : provider.data.targetWeightKg ?? fallbackTarget)
        .clamp(30.0, 200.0)
        .toDouble();
    final initialDiff = initialTarget - initialCurrent;
    final initialIsLose = initialDiff < 0;
    final initialGoalLabel = initialDiff == 0
        ? 'Duy trì vóc dáng'
        : (initialIsLose ? 'Giảm cân' : 'Tăng cơ');

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Cân nặng mục tiêu của bạn?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A0A0A),
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Điều này giúp xác định mục tiêu dinh dưỡng của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF71717A),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Horizontal Ruler Picker Card
                    IgnorePointer(
                      ignoring: goal == GoalType.maintain,
                      child: HorizontalRulerPickerCard(
                        min: 30,
                        max: 200,
                        initialValue: initialTarget,
                        primaryUnit: 'kg',
                        secondaryUnit: 'lb',
                        conversionFactor: 2.20462,
                        headerTitle: initialGoalLabel,
                        headerIcon: initialDiff == 0
                            ? Icons.balance_rounded
                            : (initialIsLose
                                ? Icons.trending_down_rounded
                                : Icons.fitness_center_rounded),
                        scrollHintText: goal == GoalType.maintain
                            ? 'Mục tiêu duy trì bằng cân nặng hiện tại'
                            : '',
                        onChanged: (v) {
                          context.read<OnboardingProvider>().setTargetWeight(v);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Difference card indicator
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, _) {
                        final current =
                            provider.data.weightKg ?? initialCurrent;
                        final target =
                            provider.data.targetWeightKg ?? initialTarget;
                        final diff = target - current;
                        final isLose = diff < 0;
                        final absDiffStr = diff.abs().toStringAsFixed(1);
                        final cardColor = diff == 0
                            ? const Color(0xFF3B82F6)
                            : (isLose
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B));
                        final statusText = diff == 0
                            ? 'Mục tiêu giữ nguyên cân nặng'
                            : (isLose
                                ? 'Mục tiêu giảm $absDiffStr kg'
                                : 'Mục tiêu tăng $absDiffStr kg');

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFF1F5F9), width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A0F172A),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cardColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  diff == 0
                                      ? Icons.balance_rounded
                                      : (isLose
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded),
                                  color: cardColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cardColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (goal == GoalType.maintain) {
                      await provider.setTargetWeight(initialCurrent);
                    }
                    await provider.nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tiếp tục',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
