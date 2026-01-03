import 'package:flutter/material.dart';

class AppTheme {
  // Night mode colors
  static const Color primaryDark = Color(0xFF1a1a2e);
  static const Color secondaryDark = Color(0xFF16213e);
  static const Color accentPurple = Color(0xFF7c3aed);
  static const Color accentBlue = Color(0xFF3b82f6);
  static const Color surfaceDark = Color(0xFF0f0f23);
  static const Color cardDark = Color(0xFF1e1e3f);
  static const Color textPrimary = Color(0xFFf8fafc);
  static const Color textSecondary = Color(0xFF94a3b8);
  static const Color starYellow = Color(0xFFfbbf24);
  static const Color moonGlow = Color(0xFFe0e7ff);
  
  // Light mode colors
  static const Color primaryLight = Color(0xFFf8fafc);
  static const Color secondaryLight = Color(0xFFe2e8f0);
  static const Color surfaceLight = Color(0xFFffffff);
  static const Color cardLight = Color(0xFFf1f5f9);
  static const Color textPrimaryLight = Color(0xFF1e293b);
  static const Color textSecondaryLight = Color(0xFF64748b);

  // Mood colors
  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFfbbf24),
    'sad': Color(0xFF60a5fa),
    'angry': Color(0xFFf87171),
    'love': Color(0xFFf472b6),
    'sleepy': Color(0xFFa78bfa),
    'neutral': Color(0xFF94a3b8),
  };

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentPurple,
    scaffoldBackgroundColor: surfaceDark,
    colorScheme: const ColorScheme.dark(
      primary: accentPurple,
      secondary: accentBlue,
      surface: surfaceDark,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentPurple,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryDark,
      selectedItemColor: accentPurple,
      unselectedItemColor: textSecondary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accentPurple,
    scaffoldBackgroundColor: primaryLight,
    colorScheme: const ColorScheme.light(
      primary: accentPurple,
      secondary: accentBlue,
      surface: surfaceLight,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textSecondaryLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentPurple,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: accentPurple,
      unselectedItemColor: textSecondaryLight,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimaryLight),
      bodyMedium: TextStyle(color: textSecondaryLight),
    ),
  );

  // Gradient backgrounds
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1a1a2e),
      Color(0xFF16213e),
      Color(0xFF0f0f23),
    ],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7c3aed),
      Color(0xFF3b82f6),
    ],
  );
}
