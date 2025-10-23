import 'package:flutter/material.dart';

class AppThemes {
  // --- "Subtle Gleam" (Light Theme) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: const Color(0xFF64B5F6), // Soft Sky Blue
    fontFamily: 'Manrope',

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: Colors.black54,
      ),
    ),

    // NEW SOFTER COLORS
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF64B5F6), // Soft Sky Blue
      secondary: Color(0xFFFFD54F), // Pale Gold
      error: Color(0xFFE57373), // Soft Salmon Red
      surface: Colors.white,
      onSurface: Colors.black87,
      background: Colors.white,
      onBackground: Colors.black87,
    ),
  );

  // --- "Deep Midnight" (Dark Theme) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: const Color(0xFF546E7A), // Deeper Blue-Grey
    fontFamily: 'Manrope',

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
    ),

    // NEW DEEP & DARK ACCENTS
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF546E7A), // Deep Blue-Grey
      secondary: Color(0xFFA1887F), // Muted Taupe (Bronze)
      error: Color(0xFFA94446), // Deep Wine Red
      surface: Colors.black,
      onSurface: Colors.white,
      background: Colors.black,
      onBackground: Colors.white,
    ),
  );
}
