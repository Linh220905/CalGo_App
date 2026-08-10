import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../widgets/premium_ui.dart';

class PaceStep extends StatefulWidget {
  const PaceStep({super.key});
  @override
  State<PaceStep> createState() => _PaceStepState();
}

class _PaceStepState extends State<PaceStep> {
  int _selected = 1;

  static const _values = [0.25, 0.5, 0.75, 1.0, 1.5];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final options = [
      s.paceSlow,
      s.paceLight,
      s.paceMedium,
      s.paceHigh,
      s.paceHighest,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(children: [
                  Text(s.paceStepTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111))),
                  const SizedBox(height: 8),
                  Text(s.paceStepSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF7A7A7A))),
                  const SizedBox(height: 24),
                  ...List.generate(
                      options.length,
                      (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: OptionCard(
                                title: options[i],
                                selected: _selected == i,
                                onTap: () => setState(() => _selected = i)),
                          )),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<OnboardingProvider>()
                        .setLossPerWeek(_values[_selected]);
                    context.read<OnboardingProvider>().nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(s.nextStepButton,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
