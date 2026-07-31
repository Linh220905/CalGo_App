import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/horizontal_ruler_picker.dart';

const _kInk = Color(0xFF0A0A0A);

class WeightStep extends StatelessWidget {
  const WeightStep({super.key});

  @override
  Widget build(BuildContext context) {
    final initialWeight =
        context.read<OnboardingProvider>().data.weightKg ?? 72.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Cân nặng của bạn là bao nhiêu?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Điều này giúp xác định mục tiêu dinh dưỡng của bạn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF71717A),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Horizontal Ruler Picker Card
                    HorizontalRulerPickerCard(
                      min: 30,
                      max: 200,
                      initialValue: initialWeight,
                      primaryUnit: 'kg',
                      secondaryUnit: 'lb',
                      conversionFactor: 2.20462,
                      headerTitle: 'Cân nặng hiện tại',
                      headerIcon: Icons.monitor_weight_outlined,
                      onChanged: (v) {
                        context.read<OnboardingProvider>().setWeight(v);
                      },
                    ),

                    const SizedBox(height: 12),
                    Consumer<OnboardingProvider>(
                      builder: (context, provider, _) {
                        final weight = provider.data.weightKg ?? initialWeight;
                        final height = provider.data.heightCm ?? 170.0;
                        final bmi = height > 0 && weight > 0
                            ? weight / ((height / 100) * (height / 100))
                            : 0.0;
                        return bmi > 0
                            ? _BmiCard(bmi: bmi, height: height, weight: weight)
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<OnboardingProvider>().nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tiếp tục',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
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

class _BmiCard extends StatelessWidget {
  final double bmi, height, weight;
  const _BmiCard(
      {required this.bmi, required this.height, required this.weight});

  Color get _statusColor {
    if (bmi < 18.5) return const Color(0xFF3B82F6);
    if (bmi < 23.0) return const Color(0xFF10B981);
    if (bmi < 27.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _label {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 23.0) return 'Bình thường';
    if (bmi < 27.5) return 'Thừa cân';
    return 'Béo phì';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;
    final gaugePct = ((bmi - 12.0) / (35.0 - 12.0)).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: BMI Header & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Chỉ số BMI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              // Status Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: BMI Score Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'kg/m²',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 3: Visual Multi-color Gradient BMI Track & Indicator
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final indicatorPos = gaugePct * trackWidth;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      // Gradient Track Bar
                      Container(
                        height: 8,
                        width: trackWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6), // Sky Blue (Gầy)
                              Color(0xFF10B981), // Emerald (Bình thường)
                              Color(0xFFF59E0B), // Amber (Thừa cân)
                              Color(0xFFEF4444), // Coral Red (Béo phì)
                            ],
                            stops: [0.0, 0.35, 0.7, 1.0],
                          ),
                        ),
                      ),

                      // Indicator Circle Pointer
                      Positioned(
                        left: (indicatorPos - 8).clamp(0.0, trackWidth - 16),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Labels under track
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gầy',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8))),
                      Text('Chuẩn',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8))),
                      Text('Thừa cân',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8))),
                      Text('Béo phì',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
