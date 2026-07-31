import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFFFAFAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color accent = Color(0xFF0F172A);
  static const Color accentLight = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color shadow = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B30);

  // ---- Dark Mode Tokens ----
  static const Color darkBg = Color(0xFF141318);
  static const Color darkSurface = Color(0xFF212027);
  static const Color darkBorder = Color(0xFF2C2A34);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF8E8D9A);

  // ---- Spacing scale ----
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // ---- Radius scale ----
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 18;
  static const double radiusXl = 28;

  // ---- Shadow token ----
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: shadow.withOpacity(0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: shadow.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ---- Motion tokens ----
  static const Duration motionFast = Duration(milliseconds: 200);
  static const Duration motionBase = Duration(milliseconds: 400);
  static const Duration motionSlow = Duration(milliseconds: 700);
  static const Curve curveBouncy = Curves.elasticOut;

  // ---- Font ----
  static String get fontFamily => GoogleFonts.beVietnamPro().fontFamily!;

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.beVietnamPro(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accent,
        surface: surface,
        error: danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _font(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: _font(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textTertiary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLg)),
          elevation: 0,
          textStyle: _font(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLg)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle: _font(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: _font(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5),
        headlineMedium: _font(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.3),
        titleLarge: _font(
            fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: _font(
            fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: _font(
            fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white,
        surface: darkSurface,
        error: danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _font(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: _font(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLg)),
          elevation: 0,
          textStyle: _font(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLg)),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          textStyle: _font(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: darkTextPrimary,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: _font(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: darkTextPrimary,
            letterSpacing: -0.5),
        headlineMedium: _font(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: darkTextPrimary,
            letterSpacing: -0.3),
        titleLarge: _font(
            fontSize: 18, fontWeight: FontWeight.w600, color: darkTextPrimary),
        bodyLarge: _font(
            fontSize: 16, fontWeight: FontWeight.w400, color: darkTextPrimary),
        bodyMedium: _font(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: darkTextSecondary),
      ),
    );
  }
}

// ---- Alias classes for backward compat ----
class AppColors {
  static Color get bg => AppTheme.bg;
  static Color get surface => AppTheme.surface;
  static Color get ink => AppTheme.textPrimary;
  static Color get textPrimary => AppTheme.textPrimary;
  static Color get textSecondary => AppTheme.textSecondary;
}

class AppSpace {
  static double get xl => AppTheme.spaceXl;
  static double get lg => AppTheme.spaceLg;
  static double get md => AppTheme.spaceMd;
  static double get sm => AppTheme.spaceSm;
  static double get xs => AppTheme.spaceXs;
}

class AppRadius {
  static double get sm => AppTheme.radiusSm;
  static double get md => AppTheme.radiusMd;
  static double get lg => AppTheme.radiusLg;
  static double get xl => AppTheme.radiusXl;
}

class AppShadow {
  static List<BoxShadow> get soft => AppTheme.softShadow;
  static List<BoxShadow> get button => AppTheme.buttonShadow;
}

class AppMotion {
  static Duration get fast => AppTheme.motionFast;
  static Duration get base => AppTheme.motionBase;
  static Duration get slow => AppTheme.motionSlow;
  static Curve get curveBouncy => AppTheme.curveBouncy;
}

class AppText {
  static TextStyle get display => GoogleFonts.beVietnamPro(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      height: 1.35,
      letterSpacing: -0.3);
  static TextStyle get headline => GoogleFonts.beVietnamPro(
      fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.textPrimary);
  static TextStyle get body => GoogleFonts.beVietnamPro(
      fontSize: 15, fontWeight: FontWeight.w400, color: AppTheme.textSecondary);
}
