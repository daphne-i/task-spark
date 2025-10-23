import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/database/database.dart';
import 'package:task_sparkle/screens/home_screen.dart';
import 'package:task_sparkle/theme/app_themes.dart';
import 'package:task_sparkle/theme/theme_cubit.dart';

// 2. main is now async
void main() async {
  // 3. Ensure bindings are ready (important for async main)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Get the SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // 5. Create the database instance
  final database = AppDatabase();

  // 6. Pass the prefs and database to MyApp
  runApp(MyApp(prefs: prefs, database: database));
}

class MyApp extends StatelessWidget {
  // 7. Add prefs and database as properties
  final SharedPreferences prefs;
  final AppDatabase database;

  const MyApp({super.key, required this.prefs, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // 8. Pass the prefs instance to the ThemeCubit
          create: (context) => ThemeCubit(prefs: prefs),
        ),
        BlocProvider(
          create: (context) {
            return TasksBloc(database: database)..add(LoadTasks());
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Task Sparkle',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
