import 'package:equatable/equatable.dart';
import 'package:task_sparkle/database/database.dart'; // Import our Task data model

// The base class for all our states
abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object> get props => [];
}

// State: "We are currently fetching tasks"
class TasksLoading extends TasksState {}

// State: "We have successfully loaded the tasks"
class TasksLoaded extends TasksState {
  final List<Task> tasks;
  // We can add categories, stats, etc., here later

  const TasksLoaded({this.tasks = const []});

  @override
  List<Object> get props => [tasks];
}

// State: "Something went wrong"
class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object> get props => [message];
}
