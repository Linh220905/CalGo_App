import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';

class VitalityDetailData {
  final String key;
  final String title;
  final String score;
  final String description;
  final String source;
  final List<MapEntry<String, String>> items;

  const VitalityDetailData({
    required this.key,
    required this.title,
    required this.score,
    required this.description,
    required this.source,
    required this.items,
  });
}

class VitalityDetailSheet extends StatelessWidget {
  final VitalityDetailData data;

  const VitalityDetailSheet({
    super.key,
    required this.data,
  });

  static Future<void> show(BuildContext context, VitalityDetailData data) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VitalityDetailSheet(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.isDarkMode;

    final sheetBg = isDark ? const Color(0xFF1A1C24) : Colors.white;
    final handleColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1);
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);
    final boxBg = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final borderColor = isDark ? const Color(0xFF2C2A34) : const Color(0xFFE2E8F0);
    final sourceColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        28 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                data.score,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Info Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: sourceColor,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        data.source,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: sourceColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (data.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              settings.strings.nutritionBreakdownTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...data.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: textDark,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              settings.strings.close,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
