import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';

class HowToAddWidgetDialog extends StatelessWidget {
  final bool isDark;

  const HowToAddWidgetDialog({super.key, required this.isDark});

  static void show(BuildContext context, {required bool isDark}) {
    showDialog(
      context: context,
      builder: (ctx) => HowToAddWidgetDialog(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppSettingsProvider>().strings;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    final bgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.widgets_outlined, color: Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.howToAddTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isIOS ? s.howToAddIosGuide : s.howToAddAndroidGuide,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: textMuted,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            s.great,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }
}
