import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/database/database.dart';
import 'package:task_sparkle/screens/add_task_screen.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final String categoryName;
  final ConfettiController confettiController;

  const TaskListItem({
    super.key,
    required this.task,
    required this.categoryName,
    required this.confettiController,
  });

  // Helper function to get the priority color
  Color _getPriorityColor(int priority, BuildContext context) {
    switch (priority) {
      case 3: // High
        return Theme.of(context).colorScheme.error;
      case 2: // Medium
        return Theme.of(context).colorScheme.secondary;
      case 1: // Low
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  // Helper to get priority as a string
  String _getPriorityString(int priority) {
    switch (priority) {
      case 3:
        return 'High Priority';
      case 2:
        return 'Medium Priority';
      case 1:
      default:
        return 'Low Priority';
    }
  }

  // Helper to format the due date
  String _formatDueDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return '• ${DateFormat('MMM d').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color priorityColor = _getPriorityColor(task.priority, context);
    final bool isCompleted = task.isCompleted;

    final priorityText = _getPriorityString(task.priority);
    final dateText = _formatDueDate(task.dueDate);
    final String subtitle = '$priorityText $dateText • $categoryName';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Compact margin
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Priority Color Border ---
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // --- 2. Checkbox ---
            Center(
              child: Checkbox(
                value: isCompleted,
                onChanged: (bool? newValue) {
                  if (newValue == null) return;
                  if (newValue == true) {
                    confettiController.play();
                  }
                  context.read<TasksBloc>().add(
                    ToggleTaskCompletion(
                      taskId: task.id,
                      isCompleted: newValue,
                    ),
                  );
                },
                activeColor: priorityColor,
                shape: const CircleBorder(),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // --- 3. Task Title & Subtitle (Tappable Area) ---
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showTaskDetails(context, task, categoryName);
                },
                onLongPress: () {
                  _showDeleteConfirmation(context); // Call the helper
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ), // Compact padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // <-- Comma is essential here
            // --- 4. Edit Button ---
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              onPressed: () {
                showModalBottomSheet(
                  context: context, // Use the build context to launch
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) {
                    // Use a different context name
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(
                          sheetContext,
                        ).viewInsets.bottom, // Use sheetContext
                      ),
                      child: AddTaskScreen(
                        task: task,
                      ), // Pass the task for edit mode
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Show Task Details Bottom Sheet ---
  void _showTaskDetails(BuildContext context, Task task, String categoryName) {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final subtitleStyle = textTheme.bodyMedium?.copyWith(
          color: textTheme.bodyMedium?.color?.withOpacity(0.7),
        );

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Title ---
                Text(
                  task.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Category & Priority ---
                Row(
                  children: [
                    Chip(
                      label: Text(
                        categoryName,
                      ), // Corrected: Named argument 'label'
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPriorityString(task.priority),
                      style: subtitleStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- Due Date (if exists) ---
                if (task.dueDate != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: subtitleStyle?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('E, MMM d, yyyy').format(task.dueDate!),
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // --- Recurring Info (if exists) ---
                if (task.isRecurring && task.frequency != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 16,
                        color: subtitleStyle?.color,
                      ),
                      const SizedBox(width: 8),
                      Text('Repeats ${task.frequency}', style: subtitleStyle),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // --- Notes (if exists) ---
                if (task.note != null && task.note!.isNotEmpty) ...[
                  Text(
                    'Notes:',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(task.note!, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ... (after the _showTaskDetails method) ...

  // --- ADD THIS HELPER METHOD ---
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
            onPressed: () {
              // Use the main context (from the widget build method)
              // to access the BLoC
              context.read<TasksBloc>().add(DeleteTask(taskId: task.id));
              Navigator.of(dialogContext).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  // --- END OF HELPER METHOD ---
}
