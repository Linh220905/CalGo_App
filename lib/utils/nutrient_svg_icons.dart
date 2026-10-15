import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 100% Custom SVG Vector Icons for Micronutrients & Vitality Indicators.
///
/// Designed strictly with vector paths — no Material Icon font or emojis.
class NutrientSvgIcons {
  NutrientSvgIcons._();

  // ── 1. Fiber (Chất xơ) ─────────────────────────────────────────────────────
  static const String _fiberSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M2 22 12 12"/>
  <path d="M7 17a4 4 0 0 0 6-6"/>
  <path d="M9 15a4 4 0 0 1 6-6"/>
  <path d="M11 13a4 4 0 0 0 6-6"/>
  <path d="M13 11a4 4 0 0 1 6-6"/>
</svg>
''';

  // ── 2. Sugar (Đường) ───────────────────────────────────────────────────────
  static const String _sugarSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
  <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
  <line x1="12" y1="22.08" x2="12" y2="12"/>
</svg>
''';

  // ── 3. Sodium (Natri) ──────────────────────────────────────────────────────
  static const String _sodiumSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M8 8h8"/>
  <path d="M7 10l1 10a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2l1-10"/>
  <path d="M9 8V5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v3"/>
  <circle cx="10" cy="14" r="0.5" fill="currentColor"/>
  <circle cx="14" cy="14" r="0.5" fill="currentColor"/>
  <circle cx="12" cy="17" r="0.5" fill="currentColor"/>
</svg>
''';

  // ── 4. Calcium (Canxi) ─────────────────────────────────────────────────────
  static const String _calciumSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  <path d="M12 8v8"/>
  <path d="M8 12h8"/>
</svg>
''';

  // ── 5. Iron (Sắt) ──────────────────────────────────────────────────────────
  static const String _ironSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="6" cy="6" r="3"/>
  <circle cx="18" cy="18" r="3"/>
  <line x1="8.5" y1="8.5" x2="15.5" y2="15.5"/>
  <line x1="4" y1="10" x2="10" y2="4"/>
  <line x1="14" y1="20" x2="20" y2="14"/>
</svg>
''';

  // ── 6. Potassium (Kali) ────────────────────────────────────────────────────
  static const String _potassiumSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/>
</svg>
''';

  // ── 7. Energy (Mức năng lượng) ────────────────────────────────────────────
  static const String _energySvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="4"/>
  <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"/>
</svg>
''';

  // ── 8. Mood & Satiety (Độ no & Tâm trạng) ──────────────────────────────────
  static const String _satietySvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"/>
  <path d="M8 14s1.5 2 4 2 4-2 4-2"/>
  <line x1="9" y1="9" x2="9.01" y2="9"/>
  <line x1="15" y1="9" x2="15.01" y2="9"/>
</svg>
''';

  // ── 9. Focus & Balance (Tập trung & Cân bằng) ──────────────────────────────
  static const String _focusSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96.44 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 4.44-2.54"/>
  <path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96.44 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-4.44-2.54"/>
</svg>
''';

  // ── 10. Lock (Khóa Premium) ────────────────────────────────────────────────
  static const String _lockSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
</svg>
''';

  // ── 11. Crown (Vương miện Pro) ─────────────────────────────────────────────
  static const String _crownSvg = '''
<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M5 16L3 5L8.5 10L12 4L15.5 10L21 5L19 16H5M19 19C19 19.6 18.6 20 18 20H6C5.4 20 5 19.6 5 19V18H19V19Z"/>
</svg>
''';

  // ── 12. Flask / Lab (Chi tiết thí nghiệm / phân tích) ───────────────────────
  static const String _flaskSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10 2v7.31L4.1 18.06A2 2 0 0 0 5.76 21h12.48a2 2 0 0 0 1.66-2.94L14 9.31V2"/>
  <path d="M8.5 2h7"/>
  <path d="M7 16h10"/>
</svg>
''';

  // ── Helper builders ────────────────────────────────────────────────────────

  static Widget _build(String rawSvg, {double size = 18, Color? color}) {
    return SvgPicture.string(
      rawSvg,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget fiber({double size = 18, Color? color}) =>
      _build(_fiberSvg, size: size, color: color);

  static Widget sugar({double size = 18, Color? color}) =>
      _build(_sugarSvg, size: size, color: color);

  static Widget sodium({double size = 18, Color? color}) =>
      _build(_sodiumSvg, size: size, color: color);

  static Widget calcium({double size = 18, Color? color}) =>
      _build(_calciumSvg, size: size, color: color);

  static Widget iron({double size = 18, Color? color}) =>
      _build(_ironSvg, size: size, color: color);

  static Widget potassium({double size = 18, Color? color}) =>
      _build(_potassiumSvg, size: size, color: color);

  static Widget energy({double size = 18, Color? color}) =>
      _build(_energySvg, size: size, color: color);

  static Widget satiety({double size = 18, Color? color}) =>
      _build(_satietySvg, size: size, color: color);

  static Widget focus({double size = 18, Color? color}) =>
      _build(_focusSvg, size: size, color: color);

  static Widget lock({double size = 18, Color? color}) =>
      _build(_lockSvg, size: size, color: color);

  static Widget crown({double size = 18, Color? color}) =>
      _build(_crownSvg, size: size, color: color);

  static Widget flask({double size = 18, Color? color}) =>
      _build(_flaskSvg, size: size, color: color);
}
