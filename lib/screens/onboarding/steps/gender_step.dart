import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(height: 24),
                    const Text('Giới tính của bạn?',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111))),
                    const SizedBox(height: 8),
                    const Text('Để tính toán chính xác hơn',
                        style:
                            TextStyle(fontSize: 15, color: Color(0xFF7A7A7A))),
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: 340,
                        child: Row(
                            children: Gender.values.map((g) {
                          final sel = _selected == g;
                          final label = g == Gender.male
                              ? 'Nam'
                              : g == Gender.female
                                  ? 'Nữ'
                                  : 'Khác';
                          const genderIcons = [
                            Icons.male,
                            Icons.female,
                            Icons.male
                          ];
                          final icon = genderIcons[Gender.values.indexOf(g)];
                          return Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(
                                left: g == Gender.male ? 0 : 8,
                                right: g == Gender.female ? 0 : 8),
                            child: _GenderCard(
                                icon: icon,
                                label: label,
                                selected: sel,
                                onTap: () => setState(() => _selected = g)),
                          ));
                        }).toList()),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
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
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFECECEC),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                  ),
                  child: const Text('Tiếp theo',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
  const _GenderCard(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: selected ? const Color(0xFFFAFAFA) : const Color(0xFFFFFFFF),
            border: Border.all(
                color: selected
                    ? const Color(0xFF111111)
                    : const Color(0xFFECECEC),
                width: selected ? 1.5 : 1)),
        child: Column(children: [
          Icon(icon, size: 44, color: Color(0xFF111111)),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111))),
        ]),
      ),
    );
  }
}
