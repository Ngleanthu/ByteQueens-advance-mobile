import 'package:flutter/material.dart';

class AppTheme {
  // Màu sắc chính
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF0D1B2A);
  static const Color navyBlue = Color(0xFF1B263B);
  static const Color mediumBlue = Color(0xFF2E4057);
  static const Color lightText = Color(0xFFE0E1DD);
  static const Color whiteText = Colors.white;

  // Light mode colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightInputBg = Color(0xFFF5F5F5);
  static const Color lightInputBorder = Color(0xFFE0E0E0);
  static const Color lightIconColor = Color(0xFF6B7280);
  static const Color lightTextColor = Color(0xFF1F2937);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0D1B2A);
  static const Color darkSurface = Color(0xFF1B263B);
  static const Color darkCard = Color(0xFF2E4057);

  // Gradient cho background
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1929),
      Color(0xFF0D1F35),
      Color(0xFF1A2942),
      Color(0xFF0F1E30),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // Theme chính
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBlue,

      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: navyBlue,
        surface: navyBlue,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: whiteText),
        titleTextStyle: TextStyle(
          color: whiteText,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: whiteText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: whiteText,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: lightText),
        bodyMedium: TextStyle(fontSize: 14, color: lightText),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navyBlue.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumBlue.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: lightText),
        hintStyle: TextStyle(color: lightText.withValues(alpha: 0.5)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          foregroundColor: whiteText,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: mediumBlue.withValues(alpha: 0.3)),
          ),
          elevation: 0,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
