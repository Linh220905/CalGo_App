import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../models/onboarding_data.dart';

class GenderStep extends StatefulWidget {
  const GenderStep({super.key});

  @override
  State<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  Gender? _selected;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      s.genderStepTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.genderStepSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: SizedBox(
                        width: 340,
                        child: Row(
                          children: Gender.values.map((g) {
                            final sel = _selected == g;
                            final label = g == Gender.male
                                ? s.genderMale
                                : g == Gender.female
                                    ? s.genderFemale
                                    : s.genderOther;
                            const genderIcons = [
                              Icons.male,
                              Icons.female,
                              Icons.transgender_rounded,
                            ];
                            final icon = genderIcons[Gender.values.indexOf(g)];
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: g == Gender.male ? 0 : 8,
                                  right: g == Gender.female ? 0 : 8,
                                ),
                                child: _GenderCard(
                                  icon: icon,
                                  label: label,
                                  selected: sel,
                                  onTap: () => setState(() => _selected = g),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _selected != null
                      ? () {
                          context
                              .read<OnboardingProvider>()
                              .setGender(_selected!);
                          context.read<OnboardingProvider>().nextStep();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFECECEC),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                  ),
                  child: Text(
                    s.nextStepButton,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
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

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
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
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? const Color(0xFFFAFAFA) : const Color(0xFFFFFFFF),
          border: Border.all(
            color: selected
                ? const Color(0xFF111111)
                : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: selected ? const Color(0xFF111111) : const Color(0xFF555555),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFF111111) : const Color(0xFF333333),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
