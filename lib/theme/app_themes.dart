import 'package:flutter/material.dart';

class AppThemes {
  // --- "GLEAM" (Light Theme) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent, // Crucial for our design
    primaryColor: const Color(0xFF6A1B9A), // A placeholder purple
    fontFamily: 'Manrope', // We'll need to add this font later
    // Define text styles
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

    // Define accent colors for priorities
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0D47A1), // Low Priority (Blue)
      secondary: Color(0xFFF9A825), // Medium Priority (Yellow)
      error: Color(0xFFB71C1C), // High Priority (Red)
      surface: Colors.white, // The "glass" tint
      onSurface: Colors.black87, // Main text color on "glass"
      background: Colors.white, // Not used, but good to define
      onBackground: Colors.black87,
    ),
  );

  // --- "MIDNIGHT" (Dark Theme) ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent, // Crucial for our design
    primaryColor: const Color(0xFFE91E63), // A placeholder pink
    fontFamily: 'Manrope', // We'll add this font later
    // Define text styles
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

    // Define accent colors for priorities
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF42A5F5), // Low Priority (Electric Blue)
      secondary: Color(0xFFFFA726), // Medium Priority (Vibrant Orange)
      error: Color(0xFFEC407A), // High Priority (Hot Pink)
      surface: Colors.black, // The "glass" tint
      onSurface: Colors.white, // Main text color on "glass"
      background: Colors.black, // Not used
      onBackground: Colors.white,
    ),
  );
}
