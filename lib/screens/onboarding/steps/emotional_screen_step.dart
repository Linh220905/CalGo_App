import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class EmotionalScreenStep extends StatelessWidget {
  const EmotionalScreenStep({super.key});

  static const _ink = Color(0xFF111111);
  static const _line = Color(0xFFE5E5E5);
  static const _surface = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    final d = context.watch<OnboardingProvider>().data;
    final currentW = d.weightKg?.toStringAsFixed(0) ?? '--';
    final futureW = d.weightInOneYearNoChange?.toStringAsFixed(0) ?? '--';
    final diff = d.weightInOneYearNoChange != null && d.weightKg != null
        ? (d.weightInOneYearNoChange! - d.weightKg!).toStringAsFixed(1)
        : '--';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                  SlideEffect(
                    begin: Offset(0, -12),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 600),
                  ),
                ],
                child: Image.asset(
                  'assets/images/apple_mascot/apple_happy.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 200),
                  ),
                ],
                child: const Text(
                  'Nếu tiếp tục ăn như hiện tại...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 400),
                  ),
                  SlideEffect(
                    begin: Offset(0, 12),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 400),
                  ),
                ],
                child: _WeightCard(
                  label: 'Hiện tại',
                  weight: '$currentW kg',
                ),
              ),
              const SizedBox(height: 12),
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 400),
                    delay: Duration(milliseconds: 700),
                  ),
                ],
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: _ink,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 800),
                  ),
                  SlideEffect(
                    begin: Offset(0, 12),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 800),
                  ),
                ],
                child: _WeightCard(
                  label: 'Sau 6 tháng',
                  weight: '$futureW kg',
                  subtitle: '+$diff kg',
                  emphasized: true,
                ),
              ),
              const SizedBox(height: 24),
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 1100),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _ink, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: _ink, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bạn gần như vẫn ở cân nặng hiện tại.\nNhưng nếu theo CalGo, bạn có thể thay đổi.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _ink,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Animate(
                effects: const [
                  FadeEffect(
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 1400),
                  ),
                  SlideEffect(
                    begin: Offset(0, 12),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 1400),
                  ),
                ],
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<OnboardingProvider>().nextStep(),
                    child: const Text('Mình sẽ giúp bạn thay đổi'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  final String label;
  final String weight;
  final String? subtitle;
  final bool emphasized;

  const _WeightCard({
    required this.label,
    required this.weight,
    this.subtitle,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: emphasized ? EmotionalScreenStep._surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EmotionalScreenStep._ink,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EmotionalScreenStep._line),
            ),
            child: Icon(
              emphasized ? Icons.trending_up_rounded : Icons.person_outline,
              color: EmotionalScreenStep._ink,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: EmotionalScreenStep._ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      weight,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: EmotionalScreenStep._ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: EmotionalScreenStep._ink,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
