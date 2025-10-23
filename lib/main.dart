import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/database/database.dart';
import 'package:task_sparkle/screens/home_screen.dart';
import 'package:task_sparkle/theme/app_themes.dart';
import 'package:task_sparkle/theme/theme_cubit.dart'; // 1. Import our new Cubit

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Create our database instance
    final AppDatabase database = AppDatabase();

    // 3. Use MultiBlocProvider to provide all our BLoCs/Cubits
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(
          create: (context) {
            return TasksBloc(database: database)..add(LoadTasks());
          },
        ),
      ],
      // 4. Use BlocBuilder to listen to the ThemeCubit's state
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          // 5. Pass the current themeMode from the Cubit to MaterialApp
          return MaterialApp(
            title: 'Task Sparkle',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme, // "Gleam"
            darkTheme: AppThemes.darkTheme, // "Midnight"
            themeMode: themeMode, // <-- This now comes from our Cubit!
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
