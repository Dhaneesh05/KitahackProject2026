import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HydroVision Liquid Glass Design System
class AppColors {
  final Color scaffoldBg;
  final Color glassBg;
  final Color glassBorder;
  final Color teal;
  final Color tealDeep;
  final Color tealLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnTeal;
  final Color divider;
  final Color shadow;

  const AppColors({
    required this.scaffoldBg,
    required this.glassBg,
    required this.glassBorder,
    required this.teal,
    required this.tealDeep,
    required this.tealLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnTeal,
    required this.divider,
    required this.shadow,
  });

  static const AppColors light = AppColors(
    scaffoldBg: Color(0xFFCEDFD8), // sage-mint green
    glassBg: Color(0xCCE8F5EF),    // frosted glass surface
    glassBorder: Color(0x99FFFFFF),  // glass rim highlight
    teal: Color(0xFF3FC9A8),         // primary teal
    tealDeep: Color(0xFF2BAE8E),     // pressed teal
    tealLight: Color(0xFFB2EBE0),    // soft teal tint
    textPrimary: Color(0xFF1A2E28),
    textSecondary: Color(0xFF5A7A72),
    textMuted: Color(0xFF93AFA8),
    textOnTeal: Color(0xFF0F2620),
    divider: Color(0x33FFFFFF),
    shadow: Color(0x1A2BAE8E),
  );

  static const AppColors dark = AppColors(
    scaffoldBg: Color(0xFF141F1C), // Deep slate-teal dark
    glassBg: Color(0x33284039), // Highly translucent tinted glass for dark
    glassBorder: Color(0x1A3FC9A8), // Subtle teal tinted glass rim
    teal: Color(0xFF3FC9A8), // Keep same bright teal
    tealDeep: Color(0xFF2BAE8E),
    tealLight: Color(0xFF1A382F), // Darker teal bubble backings
    textPrimary: Color(0xFFE8F5EF), // Bright minty white
    textSecondary: Color(0xFFA3C2B9), // Softer readablility text
    textMuted: Color(0xFF6B8A81),
    textOnTeal: Color(0xFF0F2620), // Dark text on teal buttons stays readable
    divider: Color(0x1A4DF8CB),
    shadow: Color(0x80000000), // Darker drop shadows
  );

  static AppColors of(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return dark;
    }
    return light;
  }
}

class AppTheme {
  static ThemeData get theme {
    return _buildTheme(AppColors.light, Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(AppColors.dark, Brightness.dark);
  }

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.scaffoldBg,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: colors.textPrimary,
          displayColor: colors.textPrimary,
        ),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.teal,
        onPrimary: colors.textOnTeal,
        secondary: colors.tealDeep,
        onSecondary: colors.textOnTeal,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: colors.glassBg,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: colors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
    );
  }
}
