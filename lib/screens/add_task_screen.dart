import 'dart:ui'; // For BackdropFilter
import 'package:drift/drift.dart' as drift; // Import drift with a prefix
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart';
import 'package:task_sparkle/database/database.dart'; // We need this for Category

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  Category? _selectedCategory;
  int _selectedPriority = 1; // 1: Low, 2: Medium, 3: High
  DateTime? _selectedDate;
  bool _setDeadline = false;
  bool _setReminder = false;
  bool _isRecurring = false;
  String _frequency = 'daily';

  // This is called when the "Save" button is pressed
  void _onSave() {
    if (_titleController.text.isEmpty) {
      // TODO: Show an error message
      return;
    }

    // Use the BLoC to add the task
    final tasksBloc = context.read<TasksBloc>();

    // Create the drift 'Companion' object to insert
    final taskCompanion = TasksCompanion(
      title: drift.Value(_titleController.text),
      note: drift.Value(_notesController.text),
      priority: drift.Value(_selectedPriority),
      categoryId: drift.Value(_selectedCategory?.id),
      dueDate: drift.Value(_setDeadline ? _selectedDate : null),
      isRecurring: drift.Value(_isRecurring),
      frequency: drift.Value(_isRecurring ? _frequency : null),
      // isCompleted is false by default, so we don't need to set it
    );

    // Add the event to the BLoC
    tasksBloc.add(AddTask(task: taskCompanion));

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  // Show the date picker
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current list of categories from the BLoC state
    final state = context.read<TasksBloc>().state;
    List<Category> categories = [];
    if (state is TasksLoaded) {
      categories = state.categories;
      // Set a default selected category if we have one
      if (_selectedCategory == null && categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: SingleChildScrollView(
            // Makes the content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Title and Save Button ---
                _buildHeader(),
                const SizedBox(height: 16),

                // --- Task Title Input ---
                _buildTextField(_titleController, 'Task Title'),
                const SizedBox(height: 16),

                // --- Notes Input ---
                _buildTextField(_notesController, 'Add details...'),
                const SizedBox(height: 24),

                // --- Category Dropdown ---
                _buildCategorySelector(categories),
                const SizedBox(height: 24),

                // --- Priority Selector ---
                Text('Priority', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                _buildPrioritySelector(),
                const SizedBox(height: 24),

                // --- Toggles ---
                _buildToggleRow('Set Deadline', _setDeadline, (val) {
                  setState(() {
                    _setDeadline = val;
                    if (_setDeadline && _selectedDate == null) {
                      _pickDate();
                    }
                  });
                }),
                _buildToggleRow('Set Reminder', _setReminder, (val) {
                  setState(() => _setReminder = val);
                }),
                _buildToggleRow('Make Recurring', _isRecurring, (val) {
                  setState(() => _isRecurring = val);
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable Builder Widgets ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('New Task', style: Theme.of(context).textTheme.headlineMedium),
        TextButton(
          onPressed: _onSave, // Hook up the save function
          child: Text(
            'Save',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    // A glass-style dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: (Category? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _priorityButton(1, 'Low', Theme.of(context).colorScheme.primary),
        _priorityButton(2, 'Medium', Theme.of(context).colorScheme.secondary),
        _priorityButton(3, 'High', Theme.of(context).colorScheme.error),
      ],
    );
  }

  Widget _priorityButton(int level, String label, Color color) {
    final bool isSelected = _selectedPriority == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = level;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
