import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import 'personalization_widgets.dart';

class AvoidFoodsStep extends StatefulWidget {
  const AvoidFoodsStep({super.key});

  @override
  State<AvoidFoodsStep> createState() => _AvoidFoodsStepState();
}

class _AvoidFoodsStepState extends State<AvoidFoodsStep> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final options = [
      ('seafood', s.foodSeafood),
      ('red_meat', s.foodRedMeat),
      ('egg', s.foodEggs),
      ('dairy', s.foodDairy),
      ('fried_food', s.foodFried),
      ('spicy_food', s.foodSpicy),
    ];
    return OnboardingQuestionShell(
      title: s.avoidFoodsTitle,
      note: '',
      children: [
        const SizedBox(height: 10),
        ...options.map((item) => OnboardingMultiChoiceCard(
              title: item.$2,
              selected: _selected.contains(item.$1),
              onTap: () => setState(() {
                if (_selected.contains(item.$1)) {
                  _selected.remove(item.$1);
                } else {
                  _selected.add(item.$1);
                }
              }),
            )),
      ],
      onNext: () async {
        final provider = context.read<OnboardingProvider>();
        await provider.setAvoidFoods(_selected.toList());
        if (context.mounted) await provider.nextStep();
      },
      nextLabel: s.nextStepButton,
    );
  }
}
