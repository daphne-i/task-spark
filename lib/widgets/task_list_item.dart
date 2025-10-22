import 'package:flutter/material.dart';
import 'package:task_sparkle/database/database.dart'; // Import our Task model

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color priorityColor = _getPriorityColor(task.priority, context);
    final bool isCompleted = task.isCompleted;

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
                  // TODO: Fire BLoC event to toggle completion
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
                      'High Priority • Today, 3 PM • Work', // Dummy subtext
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
                // TODO: Show edit/delete menu
              },
            ),
          ],
        ),
      ),
    );
  }
}
