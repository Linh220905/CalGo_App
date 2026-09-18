import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../utils/macro_icons.dart';

class LiveActivityConsentDialog extends StatelessWidget {
  final bool isDark;

  const LiveActivityConsentDialog({super.key, required this.isDark});

  static Future<bool?> show(BuildContext context, {required bool isDark}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LiveActivityConsentDialog(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppSettingsProvider>().strings;
    final bgColor = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final cardBg = isDark ? const Color(0xFF2A2834) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Banner at the top of dialog (Matching horizontal widget layout with calories + macros + actions)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF3B3948) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  // Calorie Ring Preview
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '2000',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        Text(
                          s.caloriesLeft,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Macros Stack Preview
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            MacroIcons.protein(size: 11),
                            const SizedBox(width: 4),
                            Text(
                              '60g',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            MacroIcons.carb(size: 11),
                            const SizedBox(width: 4),
                            Text(
                              '90g',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            MacroIcons.fat(size: 11),
                            const SizedBox(width: 4),
                            Text(
                              '30g',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Action Buttons Preview
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3B3948) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s.scanFood,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3B3948) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s.barcode,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Prompt text: "Bạn có muốn tiếp tục cho phép Hoạt động trực tiếp từ CalGo không?"
            Text(
              s.liveActivityPromptTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.liveActivityPromptDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons: "Từ chối" & "Luôn cho phép"
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor:
                          isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9),
                    ),
                    child: Text(
                      s.deny,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                    child: Text(
                      s.alwaysAllow,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
