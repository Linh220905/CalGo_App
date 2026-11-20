import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_settings_provider.dart';
import 'what_to_eat_modal.dart';

/// Circular floating action button placed just above the main `+` FAB on Home.
/// Displays a custom vector SVG cloche + sparkle icon to open the "What To Eat?"
/// dish suggestion reel without cluttering the Home header.
class WhatToEatTag extends StatelessWidget {
  final bool isDark;

  const WhatToEatTag({super.key, required this.isDark});

  static String _buildDishSparkleSvg({required bool isDark}) {
    final stroke = isDark ? '#FB923C' : '#EA580C';
    final domeFill = isDark ? '#3B281B' : '#FFF7ED';
    final sparkle = isDark ? '#FDBA74' : '#F97316';
    final highlight = isDark ? '#FDBA74' : '#FB923C';

    return '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 16.5C4 12.08 7.36 8.5 11.5 8.5C15.64 8.5 19 12.08 19 16.5H4Z" fill="$domeFill" stroke="$stroke" stroke-width="1.85" stroke-linejoin="round"/>
  <circle cx="11.5" cy="6.6" r="1.4" fill="$domeFill" stroke="$stroke" stroke-width="1.75"/>
  <path d="M7.2 13.8C7.7 12.1 9.05 11.0 10.65 10.7" stroke="$highlight" stroke-width="1.6" stroke-linecap="round"/>
  <path d="M2.5 19.2H20.5" stroke="$stroke" stroke-width="1.95" stroke-linecap="round"/>
  <path d="M19.3 2.2L19.95 4.45L22.2 5.1L19.95 5.75L19.3 8.0L18.65 5.75L16.4 5.1L18.65 4.45L19.3 2.2Z" fill="$sparkle"/>
</svg>
''';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final bg = isDark ? const Color(0xFF23212D) : Colors.white;
    final border = isDark ? const Color(0xFF4A3728) : const Color(0xFFFED7AA);

    return Tooltip(
      message: s.whatToEatTag,
      child: Semantics(
        button: true,
        label: s.whatToEatTag,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.38)
                    : const Color(0xFF0F172A).withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFF97316).withValues(
                  alpha: isDark ? 0.18 : 0.14,
                ),
                blurRadius: 14,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.lightImpact();
                WhatToEatModal.show(context, isDark: isDark);
              },
              child: Center(
                child: SvgPicture.string(
                  _buildDishSparkleSvg(isDark: isDark),
                  width: 27,
                  height: 27,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
