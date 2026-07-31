import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class SportsStep extends StatefulWidget {
  const SportsStep({super.key});
  @override
  State<SportsStep> createState() => _SportsStepState();
}

class _SportsStepState extends State<SportsStep> {
  final Set<String> _selected = {};

  static const _sports = <(String, IconData)>[
    ('Gym', Icons.fitness_center),
    ('Chạy bộ', Icons.directions_run),
    ('Đạp xe', Icons.pedal_bike),
    ('Yoga', Icons.self_improvement),
    ('Bơi', Icons.pool),
    ('Bóng đá', Icons.sports_soccer),
    ('Cầu lông', Icons.sports_tennis),
    ('Bóng rổ', Icons.sports_basketball),
    ('Khác', Icons.more_horiz),
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
                child: Column(children: [
                  const SizedBox(height: 16),
                  const Text('Bạn tập môn gì?',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111))),
                  const SizedBox(height: 8),
                  const Text('Chọn môn bạn thường tập',
                      style: TextStyle(fontSize: 15, color: Color(0xFF7A7A7A))),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemCount: _sports.length,
                    itemBuilder: (ctx, i) {
                      final (sport, icon) = _sports[i];
                      final sel = _selected.contains(sport);
                      return InkWell(
                        onTap: () => setState(() {
                          if (sel) {
                            _selected.remove(sport);
                          } else {
                            _selected.add(sport);
                          }
                        }),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
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
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon,
                                    size: 28,
                                    color: sel
                                        ? const Color(0xFF111111)
                                        : const Color(0xFF7A7A7A)),
                                const SizedBox(height: 8),
                                Text(sport,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: sel
                                            ? const Color(0xFF111111)
                                            : const Color(0xFF111111))),
                              ]),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _selected.isNotEmpty
                      ? () {
                          context
                              .read<OnboardingProvider>()
                              .setSports(_selected.toList());
                          context.read<OnboardingProvider>().nextStep();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selected.isNotEmpty
                        ? const Color(0xFF111111)
                        : const Color(0xFFECECEC),
                    foregroundColor: _selected.isNotEmpty
                        ? Colors.white
                        : const Color(0xFFAAAAAA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text('Tiếp theo',
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
