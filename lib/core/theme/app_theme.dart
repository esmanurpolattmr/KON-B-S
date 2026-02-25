import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryGreen = Color(0xFF00C896);
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color cardDark = Color(0xFF162535);
  static const Color cardDarker = Color(0xFF0F1E2E);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD740);
  static const Color errorRed = Color(0xFFFF5252);

  static const String _fontFamily = 'Outfit';

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkNavy,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentOrange,
        surface: cardDark,
        error: errorRed,
        onPrimary: darkNavy,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          color: darkNavy,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: darkNavy,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarker,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle:
            const TextStyle(fontFamily: _fontFamily, color: textSecondary),
        labelStyle:
            const TextStyle(fontFamily: _fontFamily, color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDarker,
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: textSecondary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
