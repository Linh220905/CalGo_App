import 'package:flutter/material.dart';

enum MealQualityLevel { low, healthy, normal, moderate, high }

class MealQualityResult {
  final MealQualityLevel level;
  final Color color;
  final String label;

  const MealQualityResult({
    required this.level,
    required this.color,
    required this.label,
  });
}

class NutritionCalculator {
  static MealQualityResult getMealQuality(double calo, double protein) {
    final proteinRatio = (protein * 4) / (calo <= 0 ? 1 : calo);

    if (calo > 800) {
      return const MealQualityResult(
        level: MealQualityLevel.high,
        color: Color(0xFFEF4444),
        label: 'High',
      );
    }
    if (calo > 500) {
      return const MealQualityResult(
        level: MealQualityLevel.moderate,
        color: Color(0xFFF97316),
        label: 'Moderate',
      );
    }
    if (calo <= 50) {
      return const MealQualityResult(
        level: MealQualityLevel.low,
        color: Color(0xFFD4D4D4),
        label: 'Low',
      );
    }
    if (proteinRatio > 0.15) {
      return const MealQualityResult(
        level: MealQualityLevel.healthy,
        color: Color(0xFF22C55E),
        label: 'Healthy',
      );
    }

    return const MealQualityResult(
      level: MealQualityLevel.normal,
      color: Color(0xFF6B7280),
      label: 'Normal',
    );
  }

  static Color getMealQualityBackground(MealQualityLevel level) {
    switch (level) {
      case MealQualityLevel.high:
        return const Color(0xFFFEF2F2);
      case MealQualityLevel.moderate:
        return const Color(0xFFFFF7ED);
      case MealQualityLevel.normal:
        return const Color(0xFFF5F5F5);
      case MealQualityLevel.healthy:
        return const Color(0xFFF0FDF4);
      case MealQualityLevel.low:
        return const Color(0xFFF5F5F5);
    }
  }
}
