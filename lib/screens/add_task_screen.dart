import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';
import 'package:task_sparkle/widgets/aurora_background.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // We'll use these later to store the user's input
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // Dummy data for now
  String? _selectedCategory;
  int _selectedPriority = 1; // 1: Low, 2: Medium, 3: High
  bool _setDeadline = false;
  bool _setReminder = false;
  bool _isRecurring = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This is the "Glassmorphism" card from our mockup
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            // Use the theme's glass tint
            color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the sheet fit its content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title and Save Button ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Task',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement save logic
                      Navigator.of(context).pop(); // Close the sheet
                    },
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Task Title Input ---
              TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Notes Input ---
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Add details...',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // We'll add categories, priorities, and toggles here
              Text('More options will go here...'),
              const SizedBox(height: 30), // Extra space
            ],
          ),
        ),
      ),
    );
  }
}
