import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';

class CalAiMacroCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int consumed;
  final int target;
  final double progress;
  final Color color;
  final Color trackColor;
  final Color bgIconColor;
  final Widget iconWidget;
  final bool isLocked;
  final String unit;
  final VoidCallback? onTap;

  const CalAiMacroCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.consumed,
    required this.target,
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.bgIconColor,
    required this.iconWidget,
    this.isLocked = false,
    this.unit = 'g',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final clampedPct = isLocked ? 0.0 : progress.clamp(0.0, 1.0);

    final cardBg = isDark ? const Color(0xFF212027) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final effectiveTrackColor = isDark ? const Color(0xFF2C2A34) : trackColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x22000000) : const Color(0x0A0F172A),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Locked state shows blurred placeholder, Pro state shows exact amount
              if (isLocked)
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                  child: Text(
                    '--$unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textMuted.withValues(alpha: 0.5),
                      letterSpacing: -0.3,
                    ),
                  ),
                )
              else
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isLocked ? FontWeight.w700 : FontWeight.w500,
                    color: isLocked ? textDark : textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              // Fraction: consumed / target
              if (isLocked)
                const SizedBox(height: 14)
              else
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$consumed$unit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      TextSpan(
                        text: ' / $target$unit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Ring với Icon ở giữa (blurred/faded if locked)
              Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isLocked)
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Opacity(
                            opacity: 0.55,
                            child: CustomPaint(
                              size: const Size(50, 50),
                              painter: _MacroRingPainter(
                                progress: 0.0,
                                color: color,
                                trackColor: effectiveTrackColor,
                              ),
                            ),
                          ),
                        )
                      else
                        CustomPaint(
                          size: const Size(50, 50),
                          painter: _MacroRingPainter(
                            progress: clampedPct,
                            color: color,
                            trackColor: effectiveTrackColor,
                          ),
                        ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDark ? color.withValues(alpha: 0.18) : bgIconColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: iconWidget),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _MacroRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 7) / 2;

    // Track background
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0,
    );

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MacroRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
