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
  int? _selectedCategoryId = -1;

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

    // --- 1. GET THE BLOC STATE FIRST ---
    // We use context.watch to get the current state and rebuild when it changes
    final tasksState = context.watch<TasksBloc>().state;

    // --- 2. PREPARE DATA (Handle loading/error early) ---
    List<Task> allTasks = [];
    List<Category> categories = [];
    int pendingTasksToday = 0;
    double totalProgress = 0.0;
    int totalTasks = 0;
    bool allTasksAreEmpty = true; // Assume empty initially

    Widget bodyContent; // To hold the main UI or loading/error

    if (tasksState is TasksLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (tasksState is TasksError) {
      bodyContent = Center(child: Text('Error: ${tasksState.message}'));
    } else if (tasksState is TasksLoaded) {
      // --- If loaded, calculate everything ---
      allTasks = tasksState.tasks;
      categories = tasksState.categories;
      allTasksAreEmpty = allTasks.isEmpty;

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
      pendingTasksToday = tasksDueToday
          .where((task) => !task.isCompleted)
          .length;
      final double progressToday =
          tasksDueToday
              .isEmpty // Use progressToday for display text, totalProgress for bar
          ? 0.0
          : tasksDueToday.where((task) => task.isCompleted).length /
                tasksDueToday.length;

      // Total tasks logic
      totalTasks = allTasks.length;
      final int totalCompletedTasks = allTasks
          .where((task) => task.isCompleted)
          .length;
      totalProgress = (totalTasks == 0)
          ? 0.0
          : totalCompletedTasks / totalTasks;

      // --- THE FILTER LOGIC (using the state variable _selectedCategoryId) ---
      final filteredTasks = allTasks.where((task) {
        print(
          'Filtering task ID ${task.id}. Selected Category ID: $_selectedCategoryId',
        );
        if (_selectedCategoryId == -1) {
          return true; // "All" selected
        }
        return task.categoryId == _selectedCategoryId;
      }).toList();

      // --- Assign the loaded UI to bodyContent ---
      bodyContent = _buildLoadedUI(
        context,
        screenSize,
        textTheme,
        pendingTasksToday,
        totalTasks,
        totalProgress,
        categories,
        filteredTasks, // Pass the correctly filtered list
        allTasksAreEmpty,
      );
    } else {
      // Fallback
      bodyContent = const Center(child: Text('Something went wrong.'));
    }

    // --- 3. BUILD THE SCAFFOLD ---
    // The Scaffold structure remains mostly the same
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AuroraBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  // --- Body Content (could be loading, error, or loaded UI) ---
                  Center(child: bodyContent),

                  // --- Personal Message ---
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0, bottom: 12.0),
                      child: Text(
                        'For my Husband ❤️',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                            Shadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.5),
                              blurRadius: 2,
                              offset: const Offset(-1, -1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Confetti ---
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
      floatingActionButton: // ... (Your existing FAB code remains the same) ...
      FloatingActionButton(
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

  // --- _buildLoadedUI method remains the same ---
  // --- _buildTaskList method remains the same ---
  // --- _buildDebugInfo method remains the same (you can remove it later) ---

  // ... (Keep your _buildLoadedUI, _buildTaskList, and _buildDebugInfo methods exactly as they were) ...
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
            _buildDebugInfo(filteredTasks, allTasksAreEmpty),
            const SizedBox(height: 8),
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
                        print('Filter selected: $categoryId');
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
                            value: -1,
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
  // --- THIS IS THE CORRECTED METHOD ---
  Widget _buildTaskList(
    BuildContext context,
    List<Task> filteredTasks,
    List<Category> allCategories,
    bool allTasksAreEmpty, // This flag tells us if ANY tasks exist in the app
  ) {
    // 1. Check if the FILTERED list is empty FIRST
    if (filteredTasks.isEmpty) {
      // 2. If it's empty, decide WHICH empty message to show
      if (_selectedCategoryId == -1 && allTasksAreEmpty) {
        // Check for -1
        return Center(/* ... "You have no tasks..." ... */);
      } else {
        // If tasks EXIST, but just not in this specific filter
        return Center(
          child: Text(
            // This message now correctly shows for empty categories,
            // BUT NOT when 'All' is selected and tasks exist.
            'No tasks match this filter.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }
    }

    // 3. If the filtered list is NOT empty, build the ListView
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

  // --- END OF CORRECTED METHOD ---
  // --- ADD THIS DEBUG WIDGET ---
  Widget _buildDebugInfo(List<Task> filteredTasks, bool allTasksAreEmpty) {
    // Get the current total task count from the BLoC state
    int totalTaskCount = 0;
    final state = context.read<TasksBloc>().state;
    if (state is TasksLoaded) {
      totalTaskCount = state.tasks.length;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black.withOpacity(0.5), // Semi-transparent background
      child: Text(
        'DEBUG:\n'
        'Selected Category ID: $_selectedCategoryId\n'
        'Total Tasks (from BLoC): $totalTaskCount\n'
        'Filtered Tasks Count: ${filteredTasks.length}\n'
        'All Tasks Empty Flag: $allTasksAreEmpty',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  // --- END OF ADDED WIDGET ---
} // End of _HomeScreenState class
