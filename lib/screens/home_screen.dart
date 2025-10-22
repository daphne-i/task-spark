import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart';
import 'package:task_sparkle/database/database.dart';
import 'package:task_sparkle/screens/add_task_screen.dart';
import 'package:task_sparkle/widgets/aurora_background.dart';
import 'package:task_sparkle/widgets/category_selector.dart';
import 'package:task_sparkle/widgets/glassmorphic_container.dart';
import 'package:task_sparkle/widgets/modern_progress_bar.dart';
import 'package:task_sparkle/widgets/task_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the confetti animation
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // We wrap the body in a Stack to overlay the confetti
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // This is our main UI
          AuroraBackground(
            child: SafeArea(
              child: Center(
                // This BlocBuilder rebuilds the UI when the task list changes
                child: BlocBuilder<TasksBloc, TasksState>(
                  builder: (context, state) {
                    // --- Dashboard Logic ---
                    List<Task> allTasks = [];
                    int pendingTasksToday = 0;
                    double progressToday = 0.0;

                    if (state is TasksLoaded) {
                      allTasks = state.tasks;

                      // Get the current date (ignoring time)
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      // 1. Get all tasks that are due today
                      final tasksDueToday = allTasks.where((task) {
                        if (task.dueDate == null) return false;

                        final taskDate = DateTime(
                          task.dueDate!.year,
                          task.dueDate!.month,
                          task.dueDate!.day,
                        );
                        return taskDate.isAtSameMomentAs(today);
                      }).toList();

                      // 2. From today's tasks, find out how many are pending
                      pendingTasksToday = tasksDueToday
                          .where((task) => !task.isCompleted)
                          .length;

                      // 3. Calculate progress based *only* on today's tasks
                      if (tasksDueToday.isNotEmpty) {
                        final completedToday = tasksDueToday
                            .where((task) => task.isCompleted)
                            .length;
                        progressToday = completedToday / tasksDueToday.length;
                      }
                    }
                    // --- End of Dashboard Logic ---

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
                            // Use the corrected "today" data
                            Text(
                              'You have $pendingTasksToday tasks pending today.',
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            // Use the corrected "today" progress
                            ModernProgressBar(progress: progressToday),

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

                            // This Expanded holds the list
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

          // --- Confetti Widget ---
          // This sits on top of the UI and is triggered by the controller
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            gravity: 0.1,
            emissionFrequency: 0.05,
            numberOfParticles: 10,
          ),
        ],
      ),

      // --- Floating Action Button ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the Add Task screen as a bottom sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const AddTaskScreen(),
              );
            },
          );
        },
        elevation: 0, // Remove default shadow
        backgroundColor: Colors.transparent, // Make FAB transparent
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A90E2), // Bright Blue
                Color(0xFF9013FE), // Purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // Helper widget to build the task list based on the BLoC state
  Widget _buildTaskList(BuildContext context, TasksState state) {
    if (state is TasksLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TasksError) {
      return Center(child: Text('Error loading tasks: ${state.message}'));
    }

    if (state is TasksLoaded) {
      if (state.tasks.isEmpty) {
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

          // Find the matching category from our state
          final category = state.categories.firstWhere(
            (c) => c.id == task.categoryId,
            orElse: () => const Category(id: -1, name: 'Uncategorized'),
          );

          return TaskListItem(
            task: task,
            categoryName: category.name,
            confettiController: _confettiController, // Pass the controller
          );
        },
      );
    }

    return const Center(child: Text('Something went wrong.'));
  }
}
