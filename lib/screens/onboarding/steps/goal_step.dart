import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../models/onboarding_data.dart';
import 'personalization_widgets.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) => OnboardingQuestionShell(
        title: s.goalStepTitle,
        note: s.goalStepSubtitle,
        children: [
          _GoalCard(
            icon: Icons.trending_down_rounded,
            iconColor: const Color(0xFFFF6B35),
            label: s.goalLoseWeight,
            selected: provider.data.goalType == GoalType.lose,
            onTap: () => provider.setGoalType(GoalType.lose),
          ),
          const SizedBox(height: 10),
          _GoalCard(
            icon: Icons.fitness_center_rounded,
            iconColor: const Color(0xFF007AFF),
            label: s.goalGainMuscle,
            selected: provider.data.goalType == GoalType.gain,
            onTap: () => provider.setGoalType(GoalType.gain),
          ),
          const SizedBox(height: 10),
          _GoalCard(
            icon: Icons.balance_rounded,
            iconColor: const Color(0xFF34C759),
            label: s.goalMaintain,
            selected: provider.data.goalType == GoalType.maintain,
            onTap: () => provider.setGoalType(GoalType.maintain),
          ),
        ],
        onNext: provider.data.goalType == null ? null : provider.nextStep,
        nextLabel: s.nextStepButton,
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? const Color(0xFFFAFAFA) : const Color(0xFFFFFFFF),
          border: Border.all(
            color: selected ? const Color(0xFF111111) : const Color(0xFFECECEC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected
                  ? iconColor.withOpacity(0.12)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 20,
                color: selected ? iconColor : const Color(0xFF7A7A7A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  )),
            ]),
          ),
          if (selected)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 15),
            ),
        ]),
      ),
    );
  }
}
