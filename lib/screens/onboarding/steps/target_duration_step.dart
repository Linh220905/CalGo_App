import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';

class TargetDurationStep extends StatefulWidget {
  const TargetDurationStep({super.key});
  @override
  State<TargetDurationStep> createState() => _TargetDurationStepState();
}

class _TargetDurationStepState extends State<TargetDurationStep> {
  int _weeks = 4;

  static const _options = [4, 8, 12, 16, 20, 24];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(children: [
                  const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/apple_mascot/apple_thinking.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(s.durationTitle,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111))),
                  const SizedBox(height: 8),
                  Text(s.durationNote,
                      style: TextStyle(fontSize: 15, color: Color(0xFF7A7A7A))),
                  const SizedBox(height: 32),
                  ...List.generate((_options.length + 1) ~/ 2, (row) {
                    final i = row * 2;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DurationCard(
                              weeks: _options[i],
                              label: s.weeksUnit(_options[i]),
                              unit: s.weekUnit,
                              selected: _options[i] == _weeks,
                              onTap: () => setState(() => _weeks = _options[i]),
                            ),
                          ),
                          if (i + 1 < _options.length)
                            const SizedBox(width: 12),
                          if (i + 1 < _options.length)
                            Expanded(
                              child: _DurationCard(
                                weeks: _options[i + 1],
                                label: s.weeksUnit(_options[i + 1]),
                                unit: s.weekUnit,
                                selected: _options[i + 1] == _weeks,
                                onTap: () =>
                                    setState(() => _weeks = _options[i + 1]),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
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
                    context.read<OnboardingProvider>().setTargetWeeks(_weeks);
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

class _DurationCard extends StatelessWidget {
  final int weeks;
  final String label;
  final String unit;
  final bool selected;
  final VoidCallback onTap;

  const _DurationCard({
    required this.weeks,
    required this.label,
    required this.unit,
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
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? const Color(0xFFFAFAFA) : const Color(0xFFFFFFFF),
          border: Border.all(
            color: selected ? const Color(0xFF111111) : const Color(0xFFECECEC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$weeks',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: selected
                    ? const Color(0xFF111111)
                    : const Color(0xFF111111),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xFF111111)
                    : const Color(0xFF7A7A7A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
