import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 1. Import BLoC
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart'; // 2. Import BLoC
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart'; // 3. Import BLoC
import 'package:task_sparkle/database/database.dart'; // 4. Import Task model
import 'package:task_sparkle/widgets/aurora_background.dart';
import 'package:task_sparkle/widgets/category_selector.dart';
import 'package:task_sparkle/widgets/glassmorphic_container.dart';
import 'package:task_sparkle/widgets/modern_progress_bar.dart';
import 'package:task_sparkle/widgets/task_list_item.dart'; // 5. Import our new task card
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            // 6. We wrap our UI in a BlocBuilder
            // This widget will rebuild whenever the TasksState changes
            child: BlocBuilder<TasksBloc, TasksState>(
              builder: (context, state) {
                // We'll get the real task list and stats from the state
                List<Task> tasks = [];
                int pendingTasks = 0;
                double progress = 0.0;

                if (state is TasksLoaded) {
                  tasks = state.tasks;
                  final completed = tasks.where((t) => t.isCompleted).length;
                  pendingTasks = tasks.length - completed;
                  if (tasks.isNotEmpty) {
                    progress = completed / tasks.length;
                  }
                }

                return GlassmorphicContainer(
                  width: screenSize.width * 0.9,
                  height: screenSize.height * 0.85,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. DASHBOARD HEADER ---
                        Text(
                          'Hello!',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 7. Use REAL data
                        Text(
                          'You have $pendingTasks tasks pending today.',
                          style: textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        // 8. Use REAL data
                        ModernProgressBar(progress: progress),

                        const SizedBox(height: 24),

                        // --- 2. CATEGORY SELECTOR ---
                        const CategorySelector(),

                        const SizedBox(height: 24),

                        // --- 3. TASK LIST ---
                        Text(
                          'Your Tasks',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 9. This is the main UI update
                        Expanded(child: _buildTaskList(context, state)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This is how we show the "bottom sheet"
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Allows the sheet to be tall
            backgroundColor: Colors.transparent, // Crucial for our glass effect
            builder: (context) {
              // We wrap our screen in padding to avoid the keyboard
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const AddTaskScreen(),
              );
            },
          );
        },
        // Apply the glossy gradient
        elevation: 0, // 1. Remove the default shadow
        backgroundColor:
            Colors.transparent, // 2. Make the FAB itself transparent
        child: Container(
          // 3. Use a Container for our custom button
          width: 60, // 4. Set a fixed size
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // 5. Make it perfectly round
            gradient: const LinearGradient(
              // 6. Use the "glossy" blue/purple gradient
              colors: [
                Color(0xFF4A90E2), // Bright Blue
                Color(0xFF9013FE), // Purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              // 7. Add our own soft shadow for the "lifted" look
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            // 8. Put the icon inside our custom container
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  // 10. A new helper widget to build the list based on the state
  Widget _buildTaskList(BuildContext context, TasksState state) {
    if (state is TasksLoading) {
      // Show a loading spinner
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TasksError) {
      // Show an error message
      return Center(child: Text('Error loading tasks: ${state.message}'));
    }

    if (state is TasksLoaded) {
      if (state.tasks.isEmpty) {
        // Show a friendly "empty" message
        return Center(
          child: Text(
            'You have no tasks. Add one!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }

      // We have tasks, so build the list!
      return ListView.builder(
        itemCount: state.tasks.length,
        itemBuilder: (context, index) {
          final task = state.tasks[index];
          return TaskListItem(task: task);
        },
      );
    }

    // Default "should-not-happen" state
    return const Center(child: Text('Something went wrong.'));
  }
}
