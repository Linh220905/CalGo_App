import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../models/onboarding_data.dart';

class DietStep extends StatelessWidget {
  const DietStep({super.key});

  static const _items = <(String, String, DietType)>[
    ('🍽️', 'Ăn bình thường', DietType.normal),
    ('🥗', 'Eat Clean', DietType.clean),
    ('🥓', 'Keto', DietType.keto),
    ('🌾', 'Low Carb', DietType.lowCarb),
    ('🥦', 'Vegetarian', DietType.vegetarian),
    ('🌱', 'Vegan', DietType.vegan),
  ];

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
                    const SizedBox(height: 16),
                    const Text('Chế độ ăn của bạn?',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111))),
                    const SizedBox(height: 8),
                    const Text('Chọn chế độ ăn hiện tại',
                        style:
                            TextStyle(fontSize: 15, color: Color(0xFF7A7A7A))),
                    const SizedBox(height: 24),
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, _) => Column(
                        children: _items.map((e) {
                          final (emoji, label, type) = e;
                          final sel = provider.data.dietType == type;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                provider.setDietType(type);
                                provider.nextStep();
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
                child: ElevatedButton(
                  onPressed: null,
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
