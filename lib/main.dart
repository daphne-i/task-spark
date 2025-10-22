import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 1. Import BLoC
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart'; // 2. Import our new BLoC
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart'; // 3. Import our event
import 'package:task_sparkle/database/database.dart'; // 4. Import our database
import 'package:task_sparkle/screens/home_screen.dart';
import 'package:task_sparkle/theme/app_themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. We create ONE instance of our database
    final AppDatabase database = AppDatabase();

    // 6. We wrap our entire app in a BlocProvider
    return BlocProvider(
      create: (context) {
        // 7. Create our TasksBloc and pass the database to it
        // We also immediately tell it to load all the tasks
        return TasksBloc(database: database)..add(LoadTasks());
      },
      child: MaterialApp(
        title: 'Task Sparkle',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system, // We'll add a toggle for this later
        home: const HomeScreen(),
      ),
    );
  }
}
