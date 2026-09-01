import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG Macro Icons for CalGo.
///
/// Use these instead of Material Icons for a consistent, branded look:
///   - Protein: 🥩 Meat with bone
///   - Carb: 🌾 Wheat stalk
///   - Fat: 💧 Oil drops
class MacroIcons {
  MacroIcons._();

  static const String _proteinPath = 'assets/images/ic_protein.svg';
  static const String _carbPath = 'assets/images/ic_carb.svg';
  static const String _fatPath = 'assets/images/ic_fat.svg';

  /// Returns the SVG macro icon widget.
  ///
  /// [type] is one of: 'protein', 'carb', 'fat'.
  /// [size] controls both width and height.
  /// [color] applies a color filter (optional — SVGs already have gradients).
  static Widget icon(
    String type, {
    double size = 16,
    Color? color,
  }) {
    final path = switch (type) {
      'protein' => _proteinPath,
      'carb' => _carbPath,
      'fat' => _fatPath,
      _ => _proteinPath,
    };
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget protein({double size = 16, Color? color}) =>
      icon('protein', size: size, color: color);

  static Widget carb({double size = 16, Color? color}) =>
      icon('carb', size: size, color: color);

  static Widget fat({double size = 16, Color? color}) =>
      icon('fat', size: size, color: color);
}
