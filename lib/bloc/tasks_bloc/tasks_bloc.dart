import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart';
import 'package:task_sparkle/database/database.dart'; // Import our database

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final AppDatabase database; // Our database instance

  TasksBloc({required this.database}) : super(TasksLoading()) {
    // When a 'LoadTasks' event comes in, call this function
    on<LoadTasks>(_onLoadTasks);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    try {
      // Tell the UI we are loading
      emit(TasksLoading());

      // Go to the database and get a STREAM of all tasks.
      // A stream will automatically send new data when the database changes!
      await emit.onEach<List<Task>>(
        database.watchAllTasks(),
        onData: (tasks) {
          // Every time the stream gives us a new list,
          // emit a new 'TasksLoaded' state with that list
          emit(TasksLoaded(tasks: tasks));
        },
        onError: (error, stackTrace) {
          emit(TasksError(error.toString()));
        },
      );
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
