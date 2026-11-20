import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_settings_provider.dart';
import 'what_to_eat_modal.dart';

class WhatToEatTag extends StatelessWidget {
  final bool isDark;

  const WhatToEatTag({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final tagBg = isDark ? const Color(0xFF28231E) : const Color(0xFFFFF7ED);
    final border = isDark ? const Color(0xFF4A3423) : const Color(0xFFFFEDD5);
    final textColor = isDark ? const Color(0xFFFF9D5C) : const Color(0xFFC2410C);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        WhatToEatModal.show(context, isDark: isDark);
      },
      child: Animate(
        effects: const [
          ShimmerEffect(
            delay: Duration(seconds: 3),
            duration: Duration(milliseconds: 1400),
            color: Color(0x33F97316),
          ),
        ],
        onPlay: (controller) => controller.repeat(period: const Duration(seconds: 6)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
          decoration: BoxDecoration(
            color: tagBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍲', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                s.whatToEatTag,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.casino_outlined,
                size: 14,
                color: textColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
