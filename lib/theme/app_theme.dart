import 'package:flutter/material.dart';

/// HydroVision Liquid Glass Design System
class AppColors {
  // Backgrounds
  static const Color scaffoldBg = Color(0xFFCEDFD8); // sage-mint green
  static const Color glassBg = Color(0xCCE8F5EF);    // frosted glass surface
  static const Color glassBorder = Color(0x99FFFFFF);  // glass rim highlight

  // Accents
  static const Color teal = Color(0xFF3FC9A8);         // primary teal
  static const Color tealDeep = Color(0xFF2BAE8E);     // pressed teal
  static const Color tealLight = Color(0xFFB2EBE0);    // soft teal tint

  // Text
  static const Color textPrimary = Color(0xFF1A2E28);
  static const Color textSecondary = Color(0xFF5A7A72);
  static const Color textMuted = Color(0xFF93AFA8);
  static const Color textOnTeal = Color(0xFF0F2620);

  // Utility
  static const Color divider = Color(0x33FFFFFF);
  static const Color shadow = Color(0x1A2BAE8E);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.light(
        primary: AppColors.teal,
        secondary: AppColors.tealDeep,
        surface: AppColors.glassBg,
        onPrimary: AppColors.textOnTeal,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
