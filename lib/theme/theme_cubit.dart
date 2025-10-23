import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// We'll just manage the ThemeMode enum.
// We'll start with the "Gleam" (light) theme as our default.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() {
    // If the current state is light, switch to dark.
    // Otherwise, switch to light.
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
