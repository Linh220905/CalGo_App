import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../l10n/generated/app_localizations.dart';

class LanguageSelectorButton extends StatelessWidget {
  final bool? isDark;

  const LanguageSelectorButton({super.key, this.isDark});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final dark = isDark ?? settings.isDarkMode;
    final currentCode = settings.languageCode;

    String flag = '🌐';
    if (currentCode == 'vi') flag = '🇻🇳';
    if (currentCode == 'en') flag = '🇬🇧';
    if (currentCode == 'es') flag = '🇪🇸';

    return InkWell(
      onTap: () => showLanguageSelectorModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: dark ? const Color(0xFF3F3E48) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              currentCode.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: dark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

void showLanguageSelectorModal(BuildContext context) {
  final settings = context.read<AppSettingsProvider>();
  final s = settings.strings;
  final isDark = settings.isDarkMode;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final languages = AppLocalizations.supportedLocales.map((locale) {
        final code = locale.languageCode;
        return (
          code: code,
          flag: _flagForLanguage(code),
          name: lookupAppLocalizations(locale).languageDisplayName,
          subtitle: code.toUpperCase(),
        );
      }).toList();

      return SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3F3E48)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    s.selectLanguageTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: languages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = settings.languageCode == lang.code;
                      return InkWell(
                        onTap: () {
                          settings.setLanguage(lang.code);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF2C2A34)
                                    : const Color(0xFFF1F5F9))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: isDark
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFF16A34A),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      lang.subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF8E8D9A)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: isDark
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF16A34A),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _flagForLanguage(String code) {
  switch (code) {
    case 'vi':
      return '🇻🇳';
    case 'en':
      return '🇬🇧';
    case 'es':
      return '🇪🇸';
    case 'zh':
      return '🇨🇳';
    case 'hi':
      return '🇮🇳';
    case 'ja':
      return '🇯🇵';
    case 'ko':
      return '🇰🇷';
    case 'ar':
      return '🌐';
    case 'pt':
      return '🇵🇹';
    case 'fr':
      return '🇫🇷';
    case 'bn':
      return '🇧🇩';
    case 'ru':
      return '🇷🇺';
    default:
      return '🌐';
  }
}
