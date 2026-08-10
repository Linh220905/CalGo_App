import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';

class StepProgressBar extends StatelessWidget {
  final double value;
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.value,
    this.currentStep = 0,
    this.totalSteps = 15,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s.progressLabel,
              style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          Text('${(value * 100).toInt()}%',
              style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFFECECEC),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(color: const Color(0xFF111111)),
            ),
          ),
        ),
      ]),
    );
  }
}
