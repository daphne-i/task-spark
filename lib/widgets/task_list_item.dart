import 'package:flutter/material.dart';
import 'package:task_sparkle/database/database.dart'; // Import our Task model
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final String categoryName;

  const TaskListItem({
    super.key,
    required this.task,
    required this.categoryName,
  });

  // Helper function to get the priority color
  Color _getPriorityColor(int priority, BuildContext context) {
    switch (priority) {
      case 3: // High
        return Theme.of(context).colorScheme.error; // Red
      case 2: // Medium
        return Theme.of(context).colorScheme.secondary; // Yellow
      case 1: // Low
      default:
        return Theme.of(context).colorScheme.primary; // Blue
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

  // 5. --- ADD THIS HELPER ---
  // Helper to format the due date
  String _formatDueDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    // Using intl to format the date
    // You can change 'MMM d' (e.g., Oct 23) to 'E, MMM d' (e.g., Thu, Oct 23)
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                  // Fire the BLoC event
                  context.read<TasksBloc>().add(
                    ToggleTaskCompletion(
                      taskId: task.id,
                      isCompleted: newValue,
                    ),
                  );
                },
                activeColor: priorityColor,
                // Make the checkbox round
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

            // --- 3. Task Title & Subtitle ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                        // Strikethrough if completed
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    // TODO: Add formatted date and category
                    Text(
                      subtitle, // Use our new dynamic subtitle
                      style: textTheme.bodyMedium?.copyWith(
                        color: textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 4. Edit/Menu Button (Optional) ---
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show a confirmation dialog
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Task?'),
                    content: Text(
                      'Are you sure you want to delete "${task.title}"?',
                    ),
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
                          // Fire the BLoC event
                          context.read<TasksBloc>().add(
                            DeleteTask(taskId: task.id),
                          );
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
