import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class PainStep extends StatefulWidget {
  const PainStep({super.key});

  @override
  State<PainStep> createState() => _PainStepState();
}

class _PainStepState extends State<PainStep> {
  final Set<String> _selected = {};

  static const _items = [
    'Ăn rất ít nhưng vẫn không giảm',
    'Cardio rất nhiều',
    'Bỏ cuộc sau vài ngày',
    'Không biết mình ăn bao nhiêu calo',
    'Hay bị đói giữa chừng',
    'Ăn uống stress',
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
                      'Bạn đã từng...',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Chọn những điều bạn từng gặp phải',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF71717A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._items.map((item) {
                      final sel = _selected.contains(item);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (sel) {
                                _selected.remove(item);
                              } else {
                                _selected.add(item);
                              }
                            });
                          },
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
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel
                                        ? const Color(0xFF111111)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: sel
                                          ? const Color(0xFF111111)
                                          : const Color(0xFFD0D0D0),
                                      width: sel ? 0 : 2,
                                    ),
                                  ),
                                  child: sel
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
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
                  onPressed: () {
                    final provider = context.read<OnboardingProvider>();
                    provider.setPains(_selected.toList());
                    provider.nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
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
