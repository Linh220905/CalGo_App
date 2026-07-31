import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const String _kKeyThemeMode = 'app_theme_mode';
  static const String _kKeyLanguage = 'app_language';

  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'vi'; // Mặc định: Tiếng Việt

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get languageCode => _languageCode;
  AppStrings get strings => AppStrings.of(_languageCode);

  AppSettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Theme Mode
      final isDark = prefs.getBool(_kKeyThemeMode) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      // Load Language (Default: 'vi')
      _languageCode = prefs.getString(_kKeyLanguage) ?? 'vi';

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
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kKeyLanguage, code);
    } catch (_) {}
  }
}
