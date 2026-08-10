import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _kKeyThemeMode = 'app_theme_mode';
  static const String _kKeyLanguage = 'app_language';
  static final supportedLanguageCodes = AppLocalizations.supportedLocales
      .map((locale) => locale.languageCode)
      .toSet();

  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  AppLocalizations get strings => lookupAppLocalizations(locale);

  AppSettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Theme Mode
      final isDark = prefs.getBool(_kKeyThemeMode) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      // A saved choice is explicit. Otherwise follow the device language and
      // fall back to the template locale when it is not supported.
      final savedLanguage = prefs.getString(_kKeyLanguage);
      _languageCode = _supportedOrFallback(
        savedLanguage ??
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      );

      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKeyThemeMode, isDark);
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    code = _supportedOrFallback(code);
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kKeyLanguage, code);
    } catch (_) {}
  }

  String _supportedOrFallback(String code) {
    return supportedLanguageCodes.contains(code) ? code : 'en';
  }
}
