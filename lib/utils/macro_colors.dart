import 'package:flutter/material.dart';

/// Centralized Macro Colors & Icons for CalGo
/// Standardized design tokens across all UI screens:
/// - Protein (Đạm): Pinkish Red (#FF5C5C) | Icons.fitness_center_rounded
/// - Carb (Tinh bột): Amber Yellow (#F59E0B) | Icons.grain_rounded
/// - Fat (Chất béo): Royal Blue (#3B82F6) | Icons.water_drop_rounded
class MacroColors {
  MacroColors._();

  // Primary Macro Colors
  static const Color protein = Color(0xFFFF5C5C);
  static const Color carb = Color(0xFFF59E0B);
  static const Color fat = Color(0xFF3B82F6);

  // Light Mode Backgrounds
  static const Color proteinBgLight = Color(0xFFFFECEC);
  static const Color carbBgLight = Color(0xFFFEF3C7);
  static const Color fatBgLight = Color(0xFFEFF6FF);

  // Dark Mode Track Backgrounds
  static const Color proteinTrackDark = Color(0xFF351F24);
  static const Color carbTrackDark = Color(0xFF332614);
  static const Color fatTrackDark = Color(0xFF1E293B);

  // Standardized Icons
  static const IconData proteinIcon = Icons.fitness_center_rounded;
  static const IconData carbIcon = Icons.grain_rounded;
  static const IconData fatIcon = Icons.water_drop_rounded;
}
