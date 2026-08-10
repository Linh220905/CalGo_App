import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../models/onboarding_data.dart';

class DietStep extends StatelessWidget {
  const DietStep({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;
    final items = <(String, String, DietType)>[
      ('🍽️', s.dietNormal, DietType.normal),
      ('🥗', s.dietClean, DietType.clean),
      ('🥓', s.dietKeto, DietType.keto),
      ('🌾', s.dietLowCarb, DietType.lowCarb),
      ('🥦', s.dietVegetarian, DietType.vegetarian),
      ('🌱', s.dietVegan, DietType.vegan),
    ];

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
                    const SizedBox(height: 16),
                    Text(s.dietStepTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111))),
                    const SizedBox(height: 8),
                    Text(s.dietStepSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Color(0xFF7A7A7A))),
                    const SizedBox(height: 24),
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, _) => Column(
                        children: items.map((e) {
                          final (emoji, label, type) = e;
                          final sel = provider.data.dietType == type;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                provider.setDietType(type);
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: sel
                                        ? const Color(0xFFFAFAFA)
                                        : const Color(0xFFFFFFFF),
                                    border: Border.all(
                                        color: sel
                                            ? const Color(0xFF111111)
                                            : const Color(0xFFECECEC),
                                        width: sel ? 1.5 : 1)),
                                child: Row(children: [
                                  Text(emoji,
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Text(label,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF111111)))),
                                  if (sel)
                                    Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                            color: Color(0xFF111111),
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 14)),
                                ]),
                              ),
                            ),
                          );
                        }).toList(),
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
                child: Consumer<OnboardingProvider>(
                  builder: (context, provider, _) => ElevatedButton(
                    onPressed: provider.data.dietType == null
                        ? null
                        : () => provider.nextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFECECEC),
                      disabledForegroundColor: const Color(0xFFAAAAAA),
                    ),
                    child: Text(s.nextStepButton,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
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
