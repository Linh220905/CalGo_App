import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import 'personalization_widgets.dart';

class BudgetStep extends StatefulWidget {
  const BudgetStep({super.key});

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  String _selected = '30_60k';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final options = [
      ('under_30k', s.budgetLow, s.budgetLowNote),
      ('30_60k', s.budgetMid, s.budgetMidNote),
      ('60_100k', s.budgetHigh, s.budgetHighNote),
      ('any', s.budgetAny, s.budgetAnyNote),
    ];
    return OnboardingQuestionShell(
      title: s.budgetTitle,
      note: s.budgetNote,
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
        await provider.setBudgetPreference(_selected);
        if (context.mounted) await provider.nextStep();
      },
      nextLabel: s.nextStepButton,
    );
  }
}
