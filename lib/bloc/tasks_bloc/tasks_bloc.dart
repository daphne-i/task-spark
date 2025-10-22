import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart';
import 'package:task_sparkle/database/database.dart'; // Import our database

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final AppDatabase database; // Our database instance
  List<Category> _categories = [];

  TasksBloc({required this.database}) : super(TasksLoading()) {
    // When a 'LoadTasks' event comes in, call this function
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    try {
      // Tell the UI we are loading
      emit(TasksLoading());
      _categories = await database.getAllCategories();

      // Go to the database and get a STREAM of all tasks.
      // A stream will automatically send new data when the database changes!
      await emit.onEach<List<Task>>(
        database.watchAllTasks(),
        onData: (tasks) {
          // Every time the stream gives us a new list,
          // emit a new 'TasksLoaded' state with that list
          emit(TasksLoaded(tasks: tasks, categories: _categories));
        },
        onError: (error, stackTrace) {
          emit(TasksError(error.toString()));
        },
      );
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    try {
      await database.addTask(event.task);
      // We don't need to emit a new state here, because...
      // ...our _onLoadTasks stream is *watching* the database.
      // As soon as the task is added, the stream will automatically
      // fire, and _onLoadTasks will emit a new TasksLoaded state.
      // This is the power of reactive programming!
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
