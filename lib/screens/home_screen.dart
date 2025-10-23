import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart';
import 'package:task_sparkle/database/database.dart';
import 'package:task_sparkle/screens/add_task_screen.dart';
import 'package:task_sparkle/theme/theme_cubit.dart';
import 'package:task_sparkle/widgets/aurora_background.dart';
import 'package:task_sparkle/widgets/glassmorphic_container.dart';
import 'package:task_sparkle/widgets/modern_progress_bar.dart';
import 'package:task_sparkle/widgets/task_list_item.dart';
import 'package:task_sparkle/screens/scratch_pad_screen.dart'; // <-- Import Scratch Pad

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  int? _selectedCategoryId;

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AuroraBackground(
            child: SafeArea(
              //
              // --- THIS IS THE NEWLY ADDED CODE ---
              //
              // We wrap the old 'Center' widget in a 'Stack'
              // to layer the text over the top.
              child: Stack(
                children: [
                  // This Center widget holds all your existing app UI
                  Center(
                    child: BlocBuilder<TasksBloc, TasksState>(
                      builder: (context, state) {
                        // --- 1. HANDLE LOADING/ERROR STATES FIRST ---
                        if (state is TasksLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is TasksError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }

                        // --- 2. IF WE ARE LOADED, PREPARE ALL DATA ---
                        if (state is TasksLoaded) {
                          final allTasks = state.tasks;
                          final categories = state.categories;
                          // --- CORRECTED SORTING BLOCK ---
                          final sortedTasks = List<Task>.from(
                            allTasks,
                          ); // Create a modifiable copy
                          sortedTasks.sort((a, b) {
                            // Rule 1: Completed tasks go to the bottom
                            if (a.isCompleted && !b.isCompleted)
                              return 1; // a goes after b
                            if (!a.isCompleted && b.isCompleted)
                              return -1; // a goes before b

                            // If both are completed or both are open, proceed.
                            // We only actively sort the *open* tasks among themselves.
                            if (!a.isCompleted) {
                              // Only sort if both are open
                              bool aHasDate = a.dueDate != null;
                              bool bHasDate = b.dueDate != null;

                              // Rule 2 vs 3: Tasks with dates come before tasks without
                              if (aHasDate && !bHasDate)
                                return -1; // a (with date) comes first
                              if (!aHasDate && bHasDate)
                                return 1; // b (with date) comes first

                              // Rule 2: Both have due dates
                              if (aHasDate && bHasDate) {
                                // Sort by due date (nearest first - ASCENDING)
                                int dateCompare = a.dueDate!.compareTo(
                                  b.dueDate!,
                                );
                                if (dateCompare != 0) return dateCompare;

                                // Same date, sort by priority (highest first - DESCENDING)
                                // Higher priority value (3) should come before lower (1)
                                return b.priority.compareTo(a.priority);
                              }

                              // Rule 3: Both are open, neither has a due date
                              if (!aHasDate && !bHasDate) {
                                // Sort by priority (highest first - DESCENDING)
                                return b.priority.compareTo(a.priority);
                              }
                            }

                            // For completed tasks, or if priorities/dates are equal,
                            // maintain their relative order (or sort by ID for stability)
                            return a.id.compareTo(b.id);
                          });
                          // --- END OF CORRECTED SORTING BLOCK ---
                          // --- 3. DO ALL LOGIC HERE ---
                          // Dashboard Logic
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final tasksDueToday = allTasks.where((task) {
                            if (task.dueDate == null) return false;
                            final taskDate = DateTime(
                              task.dueDate!.year,
                              task.dueDate!.month,
                              task.dueDate!.day,
                            );
                            return taskDate.isAtSameMomentAs(today);
                          }).toList();
                          final pendingTasksToday = tasksDueToday
                              .where((task) => !task.isCompleted)
                              .length;
                          final double progressToday = tasksDueToday.isEmpty
                              ? 0.0
                              : tasksDueToday
                                        .where((task) => task.isCompleted)
                                        .length /
                                    tasksDueToday.length;

                          // Total tasks logic
                          final int totalTasks = allTasks.length;
                          final int totalCompletedTasks = allTasks
                              .where((task) => task.isCompleted)
                              .length;
                          final double totalProgress = (totalTasks == 0)
                              ? 0.0
                              : totalCompletedTasks / totalTasks;

                          // --- 4. THE CORRECT FILTER LOGIC ---
                          final filteredTasks = sortedTasks.where((task) {
                            if (_selectedCategoryId == null) {
                              return true; // "All" is selected
                            }
                            return task.categoryId == _selectedCategoryId;
                          }).toList();

                          // --- 5. RETURN THE UI ---
                          return _buildLoadedUI(
                            context,
                            screenSize,
                            textTheme,
                            pendingTasksToday,
                            totalTasks, // Pass total tasks
                            totalProgress, // Pass total progress
                            categories,
                            filteredTasks, // Pass the filtered list
                            allTasks
                                .isEmpty, // Pass a flag for the "empty" message
                          );
                        }

                        // Default fallback
                        return const Center(
                          child: Text('Something went wrong.'),
                        );
                      },
                    ),
                  ),

                  // --- THIS IS THE PERSONAL MESSAGE WIDGET ---
                  // It's aligned to the bottom center of the Stack
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0, bottom: 12.0),
                      child: Text(
                        'Husband ❤️',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            // Darker shadow for the 'pressed-in' effect
                            Shadow(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withOpacity(0.2), // Subtle dark
                              blurRadius: 5,
                              offset: const Offset(1, 1),
                            ),
                            // Lighter highlight for the 'raised' edge
                            Shadow(
                              color: Theme.of(context).colorScheme.surface
                                  .withOpacity(0.5), // Subtle light
                              blurRadius: 5,
                              offset: const Offset(-1, -1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // --- END OF NEWLY ADDED CODE ---
                ],
              ),
            ),
          ),

          // --- Confetti Widget ---
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDarkMode
                ? const LinearGradient(
                    // "Deep Midnight" FAB
                    colors: [Color(0xFF546E7A), Color(0xFF004D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    // "Subtle Gleam" FAB
                    colors: [Color(0xFF64B5F6), Color(0xFF9575CD)],
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

  // --- This is a "dumb" widget that just builds the UI ---
  Widget _buildLoadedUI(
    BuildContext context,
    Size screenSize,
    TextTheme textTheme,
    int pendingTasksToday,
    int totalTasks, // Added
    double totalProgress, // Changed from progressToday
    List<Category> categories,
    List<Task> filteredTasks,
    bool allTasksAreEmpty,
  ) {
    return GlassmorphicContainer(
      width: screenSize.width * 0.9,
      height: screenSize.height * 0.92, // Taller size
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 16.0,
        ), // Compact padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DASHBOARD HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello!',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    context.watch<ThemeCubit>().state == ThemeMode.light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 28,
                  ),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ],
            ),
            // Updated Text
            Text(
              'You have $pendingTasksToday tasks pending today, out of $totalTasks total tasks.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12), // Compact
            // Updated Progress Bar
            ModernProgressBar(progress: totalProgress),
            const SizedBox(height: 16), // Compact
            // --- 2. TASK LIST HEADER WITH FILTER ---
            // --- 2. TASK LIST HEADER WITH FILTER & CLEAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Tasks',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // We add a new Row to hold the two icons
                Row(
                  children: [
                    // --- NEW CLEAR BUTTON ---
                    IconButton(
                      icon: Icon(
                        Icons.cleaning_services_rounded,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        size:
                            22, // Make it slightly smaller than the filter icon
                      ),
                      onPressed: () {
                        // Show a confirmation dialog
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Clear Completed Tasks?'),
                            content: const Text(
                              'Are you sure you want to delete all completed tasks? This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                child: const Text('Clear All'),
                                onPressed: () {
                                  // Fire the BLoC event
                                  context.read<TasksBloc>().add(
                                    ClearCompletedTasks(),
                                  );
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons
                            .description_outlined, // Or Icons.notes_rounded, Icons.description_outlined
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        size: 22,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Important for keyboard
                          backgroundColor:
                              Colors.transparent, // Let the sheet handle color
                          // Use a slightly different elevation/barrier color if desired
                          barrierColor: Colors.black.withOpacity(0.6),
                          builder: (context) {
                            // Add padding to push the sheet up when keyboard appears
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                              ),
                              child: const ScratchPadScreen(),
                            );
                          },
                        );
                      },
                    ),
                    // --- EXISTING FILTER BUTTON ---
                    PopupMenuButton<int?>(
                      onSelected: (int? categoryId) {
                        setState(() {
                          _selectedCategoryId = categoryId;
                        });
                      },
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      itemBuilder: (context) {
                        List<PopupMenuEntry<int?>> items = [];
                        items.add(
                          const PopupMenuItem<int?>(
                            value: null,
                            child: Text('All'),
                          ),
                        );
                        items.add(const PopupMenuDivider());
                        items.addAll(
                          categories.map((category) {
                            return PopupMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }),
                        );
                        return items;
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10), // Compact
            // --- 3. THE TASK LIST ---
            Expanded(
              child: _buildTaskList(
                context,
                filteredTasks,
                categories,
                allTasksAreEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- This just builds the list it's given ---
  Widget _buildTaskList(
    BuildContext context,
    List<Task> filteredTasks,
    List<Category> allCategories,
    bool allTasksAreEmpty,
  ) {
    if (filteredTasks.isEmpty) {
      if (_selectedCategoryId == null && allTasksAreEmpty) {
        return Center(
          child: Text(
            'You have no tasks. Add one!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      } else {
        return Center(
          child: Text(
            'No tasks in this category.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];

        final category = allCategories.firstWhere(
          (c) => c.id == task.categoryId,
          orElse: () => const Category(id: -1, name: 'Uncategorized'),
        );

        return TaskListItem(
          task: task,
          categoryName: category.name,
          confettiController: _confettiController,
        );
      },
    );
  }
}
