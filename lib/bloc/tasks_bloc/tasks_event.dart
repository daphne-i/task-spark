import 'package:equatable/equatable.dart';

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
class AddTask extends TasksEvent {}

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
