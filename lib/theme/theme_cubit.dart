import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  // 1. A key to store our value
  static const String _themeKey = 'isDarkMode';

  ThemeCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      // 2. Load the initial theme FROM prefs when the Cubit is created
      super(_loadInitialTheme(prefs));

  // 3. A static helper function to get the initial value
  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    // Try to get the saved boolean, defaulting to 'false' (light)
    final isDark = prefs.getBool(_themeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // 4. Our toggle function now ALSO saves the choice
  void toggleTheme() {
    final newMode = (state == ThemeMode.light)
        ? ThemeMode.dark
        : ThemeMode.light;

    // 5. Save the new choice to SharedPreferences
    _prefs.setBool(_themeKey, newMode == ThemeMode.dark);

    // 6. Emit the new state to the UI
    emit(newMode);
  }
}
