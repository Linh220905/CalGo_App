import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import 'personalization_widgets.dart';

class PrepTimeStep extends StatefulWidget {
  const PrepTimeStep({super.key});

  @override
  State<PrepTimeStep> createState() => _PrepTimeStepState();
}

class _PrepTimeStepState extends State<PrepTimeStep> {
  String _selected = '10_20';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final options = [
      ('under_10', s.prepShort, s.prepShortNote),
      ('10_20', s.prepMedium, s.prepMediumNote),
      ('over_20', s.prepLong, s.prepLongNote),
      ('any', s.prepAny, s.prepAnyNote),
    ];
    return OnboardingQuestionShell(
      title: s.prepTitle,
      note: s.prepNote,
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
        await provider.setPrepTimePreference(_selected);
        if (context.mounted) await provider.nextStep();
      },
      nextLabel: s.nextStepButton,
    );
  }
}
