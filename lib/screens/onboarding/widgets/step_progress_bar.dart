import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFF1F5F9),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF111111),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
