import 'package:equatable/equatable.dart';
import 'package:task_sparkle/database/database.dart'; // <-- Add this line

// The base class for all our events
abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object> get props => [];
}

// Event: "Load all tasks from the database"
class LoadTasks extends TasksEvent {}

// Event: "Add a new task"
// (We'll add more details to this later)
class AddTask extends TasksEvent {
  // A TasksCompanion is the drift-generated object for inserting a new row
  final TasksCompanion task;

  const AddTask({required this.task});

  @override
  List<Object> get props => [task];
}

// Event: "Mark a task as complete/incomplete"
class ToggleTaskCompletion extends TasksEvent {
  final int taskId;
  final bool isCompleted;

  const ToggleTaskCompletion({required this.taskId, required this.isCompleted});

  @override
  List<Object> get props => [taskId, isCompleted];
}

// Event: "Delete a task"
class DeleteTask extends TasksEvent {
  final int taskId;

  const DeleteTask({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class EditTask extends TasksEvent {
  final int taskId;
  final TasksCompanion task; // The new data

  const EditTask({required this.taskId, required this.task});

  @override
  List<Object> get props => [taskId, task];
}
