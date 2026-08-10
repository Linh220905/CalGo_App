import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import 'personalization_widgets.dart';

class NutritionPriorityStep extends StatefulWidget {
  const NutritionPriorityStep({super.key});

  @override
  State<NutritionPriorityStep> createState() => _NutritionPriorityStepState();
}

class _NutritionPriorityStepState extends State<NutritionPriorityStep> {
  String _selected = 'balanced';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final options = [
      ('high_protein', s.priorityProtein, s.priorityProteinNote),
      ('light', s.priorityLight, s.priorityLightNote),
      ('balanced', s.priorityBalanced, s.priorityBalancedNote),
      ('full', s.priorityFilling, s.priorityFillingNote),
    ];
    return OnboardingQuestionShell(
      title: s.nutritionPriorityTitle,
      note: s.nutritionPriorityNote,
      children: options
          .map((item) => OnboardingChoiceCard(
                title: item.$2,
                subtitle: item.$3,
                selected: _selected == item.$1,
                onTap: () => setState(() => _selected = item.$1),
              ))
          .toList(),
      onNext: () async {
        final provider = context.read<OnboardingProvider>();
        await provider.setNutritionPriority(_selected);
        if (context.mounted) await provider.nextStep();
      },
      nextLabel: s.nextStepButton,
    );
  }
}
