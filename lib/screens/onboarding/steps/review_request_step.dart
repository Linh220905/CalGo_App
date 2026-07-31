import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/premium_ui.dart';

class ReviewRequestStep extends StatefulWidget {
  const ReviewRequestStep({super.key});

  @override
  State<ReviewRequestStep> createState() => _ReviewRequestStepState();
}

class _ReviewRequestStepState extends State<ReviewRequestStep> {
  int _rating = 5;
  bool _submitted = false;

  static const _labels = [
    'Tệ',
    'Cần cải thiện',
    'Tạm ổn',
    'Rất tốt!',
    'Tuyệt vời! ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                  ScaleEffect(
                    begin: Offset(0.9, 0.9),
                    end: Offset(1, 1),
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                  ),
                ],
                child: Image.asset(
                  'assets/images/apple_mascot/apple_happy.png',
                  width: 130,
                  height: 130,
                ),
              ),
              const SizedBox(height: 24),
              if (!_submitted) ...[
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 600)),
                    SlideEffect(
                      begin: Offset(0, -10),
                      end: Offset.zero,
                      duration: Duration(milliseconds: 600),
                    ),
                  ],
                  child: const Text(
                    'Bạn thấy CalGo thế nào?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 600)),
                  ],
                  child: const Text(
                    'Đánh giá của bạn giúp CalGo hoàn thiện hơn mỗi ngày',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF71717A),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Star selector card
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          final active = i < _rating;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _rating = i + 1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                active
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 40,
                                color: active
                                    ? const Color(0xFFFFB800)
                                    : const Color(0xFFD4D4D8),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _labels[_rating - 1],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                PremiumButton(
                  label: 'Gửi đánh giá',
                  onPressed: () {
                    final provider = context.read<OnboardingProvider>();
                    provider.setLikedApp(_rating >= 4);
                    setState(() => _submitted = true);
                  },
                ),
              ] else ...[
                Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 400)),
                    ScaleEffect(
                      begin: Offset(0.85, 0.85),
                      end: Offset(1, 1),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                    ),
                  ],
                  child: const Text(
                    'Cảm ơn bạn rất nhiều! ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Animate(
                  effects: const [
                    FadeEffect(
                        duration: Duration(milliseconds: 500),
                        delay: Duration(milliseconds: 150)),
                  ],
                  child: Text(
                    _rating >= 4
                        ? 'Sự ủng hộ của bạn là động lực tuyệt vời để CalGo đồng hành cùng bạn!'
                        : 'CalGo đã ghi nhận ý kiến để cải thiện ứng dụng tốt hơn!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF71717A),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_submitted)
                Animate(
                  effects: const [
                    FadeEffect(
                        duration: Duration(milliseconds: 500),
                        delay: Duration(milliseconds: 300)),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PremiumButton(
                      label: 'Tiếp tục',
                      onPressed: () =>
                          context.read<OnboardingProvider>().nextStep(),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
