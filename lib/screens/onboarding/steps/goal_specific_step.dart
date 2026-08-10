import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/onboarding_data.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'personalization_widgets.dart';

/// One short, free goal-specific question.  The existing onboarding questions
/// remain unchanged; this screen only adds the one branch that matches the
/// selected goal.
class GoalSpecificStep extends StatefulWidget {
  const GoalSpecificStep({super.key});

  @override
  State<GoalSpecificStep> createState() => _GoalSpecificStepState();
}

class _GoalSpecificStepState extends State<GoalSpecificStep> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final data = context.read<OnboardingProvider>().data;
    _selected = switch (data.goalType) {
      GoalType.lose => data.biggestChallenge,
      GoalType.gain => data.trainingFrequency,
      GoalType.maintain => data.maintenanceFocus,
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final provider = context.watch<OnboardingProvider>();
    final copy = _copyFor(provider.data.goalType, settings.strings);

    return OnboardingQuestionShell(
      title: copy.title,
      note: '',
      children: copy.options
          .map((option) => OnboardingChoiceCard(
                title: option.label,
                subtitle: '',
                selected: _selected == option.value,
                onTap: () => setState(() => _selected = option.value),
              ))
          .toList(),
      onNext: _selected == null ? null : _saveAndContinue,
      nextLabel: settings.strings.nextStepButton,
    );
  }

  Future<void> _saveAndContinue() async {
    final provider = context.read<OnboardingProvider>();
    final value = _selected;
    if (value == null) return;

    switch (provider.data.goalType) {
      case GoalType.lose:
        await provider.setBiggestChallenge(value);
      case GoalType.gain:
        await provider.setTrainingFrequency(value);
      case GoalType.maintain:
        await provider.setMaintenanceFocus(value);
      case null:
        return;
    }
    if (mounted) await provider.nextStep();
  }

  _GoalCopy _copyFor(GoalType? goal, AppLocalizations s) {
    if (goal == GoalType.gain) {
      return _GoalCopy(
        title: s.goalSpecificGainTitle,
        options: [
          _GoalOption('none', s.goalSpecificGainNone),
          _GoalOption('1_2', s.goalSpecificGain12),
          _GoalOption('3_4', s.goalSpecificGain34),
          _GoalOption('5_plus', s.goalSpecificGain5),
        ],
      );
    }

    if (goal == GoalType.maintain) {
      return _GoalCopy(
        title: s.goalSpecificMaintainTitle,
        options: [
          _GoalOption('stable_weight', s.goalSpecificStable),
          _GoalOption('balanced_eating', s.goalSpecificBalanced),
          _GoalOption('long_term_habits', s.goalSpecificHabits),
          _GoalOption('weekend_control', s.goalSpecificWeekends),
        ],
      );
    }

    return _GoalCopy(
      title: s.goalSpecificLoseTitle,
      options: [
        _GoalOption('hunger', s.goalSpecificHunger),
        _GoalOption('portion_control', s.goalSpecificPortions),
        _GoalOption('meal_choices', s.goalSpecificChoices),
        _GoalOption('logging', s.goalSpecificLogging),
        _GoalOption('night_eating', s.goalSpecificOvereat),
        _GoalOption('weekends', s.goalSpecificWeekendsHard),
      ],
    );
  }
}

class _GoalCopy {
  final String title;
  final List<_GoalOption> options;

  const _GoalCopy({required this.title, required this.options});
}

class _GoalOption {
  final String value;
  final String label;

  const _GoalOption(this.value, this.label);
}
