import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  final Color iconColor;

  const AppColors._({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
    required this.iconColor,
  });

  static const AppColors dark = AppColors._(
    primary: Color(0xFF20A2DF),
    secondary: Color(0xFFE50914),
    background: Color(0xFF000000),
    surface: Color(0xFF121212),
    card: Color(0xFF1C1C1C),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Colors.grey,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    iconColor: Colors.white,
  );

  static const AppColors light = AppColors._(
    primary: Color(0xFF20A2DF),
    secondary: Color(0xFFE50914),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFEEEEEE),
    card: Color(0xFFD0D0D0),
    textPrimary: Colors.black,
    textSecondary: Colors.black54,
    textMuted: Colors.grey,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    iconColor: Colors.black,
  );
}

class AppTheme {
  static ThemeData getTheme(AppColors colors, {required bool isDark}) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'Nunito',

      scaffoldBackgroundColor: colors.background,

      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.onPrimary,
        onSecondary: colors.onSecondary,
        onSurface: colors.onSurface,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.iconColor),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: colors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: colors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: colors.textSecondary,
          fontSize: 14,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        labelStyle: TextStyle(color: colors.textSecondary),
        prefixIconColor: colors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => getTheme(AppColors.dark, isDark: true);
  static ThemeData get lightTheme => getTheme(AppColors.light, isDark: false);
}