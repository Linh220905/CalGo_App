import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import 'personalization_widgets.dart';

class HabitStep extends StatefulWidget {
  const HabitStep({super.key});

  @override
  State<HabitStep> createState() => _HabitStepState();
}

class _HabitStepState extends State<HabitStep> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final items = [
      s.habitRegular,
      s.habitSnacking,
      s.habitSkipBreakfast,
      s.habitLateNight,
      s.habitEatingOut,
      s.habitCook,
    ];
    return OnboardingQuestionShell(
      title: s.habitTitle,
      note: s.habitNote,
      children: items
          .map((item) => OnboardingChoiceCard(
                title: item,
                subtitle: '',
                selected: _selected == item,
                onTap: () => setState(() => _selected = item),
              ))
          .toList(),
      onNext: _selected == null
          ? null
          : () async {
              final provider = context.read<OnboardingProvider>();
              await provider.setHabitPattern(_selected!);
              if (context.mounted) await provider.nextStep();
            },
      nextLabel: s.nextStepButton,
    );
  }
}
