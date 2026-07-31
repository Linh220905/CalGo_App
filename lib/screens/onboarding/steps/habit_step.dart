import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class HabitStep extends StatefulWidget {
  const HabitStep({super.key});

  @override
  State<HabitStep> createState() => _HabitStepState();
}

class _HabitStepState extends State<HabitStep> {
  String? _selected;

  static const _items = [
    'Ăn đúng bữa, khoa học',
    'Hay ăn vặt',
    'Thường bỏ bữa sáng',
    'Ăn đêm',
    'Ăn ngoài nhiều',
    'Tự nấu ở nhà',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.asset(
                      'assets/images/apple_mascot/apple_thinking.png',
                      height: 105,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Thói quen ăn uống\ncủa bạn?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._items.map((item) {
                      final sel = _selected == item;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selected = item),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: sel
                                  ? const Color(0xFFFAFAFA)
                                  : const Color(0xFFFFFFFF),
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFF111111)
                                    : const Color(0xFFECECEC),
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(item,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111111))),
                                ),
                                if (sel)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF111111),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white, size: 14),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
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
                          final provider = context.read<OnboardingProvider>();
                          provider.setHabitPattern(_selected ?? '');
                          provider.nextStep();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected != null
                        ? const Color(0xFF111111)
                        : const Color(0xFFECECEC),
                    foregroundColor: _selected != null
                        ? Colors.white
                        : const Color(0xFFAAAAAA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
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
