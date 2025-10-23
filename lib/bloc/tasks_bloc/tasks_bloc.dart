import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_event.dart';
import 'package:task_sparkle/bloc/tasks_bloc/tasks_state.dart';
import 'package:task_sparkle/database/database.dart'; // Import our database
import 'package:jiffy/jiffy.dart';
import 'package:drift/drift.dart' as drift;

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final AppDatabase database; // Our database instance
  List<Category> _categories = [];

  TasksBloc({required this.database}) : super(TasksLoading()) {
    // When a 'LoadTasks' event comes in, call this function
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<DeleteTask>(_onDeleteTask);
    on<EditTask>(_onEditTask);
    on<ClearCompletedTasks>(_onClearCompletedTasks);
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

  DateTime _calculateNextDueDate(DateTime currentDueDate, String frequency) {
    final jiffy = Jiffy.parseFromDateTime(currentDueDate);
    switch (frequency) {
      case 'daily':
        return jiffy.add(days: 1).dateTime;
      case 'weekly':
        return jiffy.add(weeks: 1).dateTime;
      case 'monthly':
        return jiffy.add(months: 1).dateTime;
      case 'quarterly':
        return jiffy.add(months: 3).dateTime;
      case 'half-yearly':
        return jiffy.add(months: 6).dateTime;
      case 'yearly':
        return jiffy.add(years: 1).dateTime;
      default:
        // Default to weekly if something is wrong
        return jiffy.add(weeks: 1).dateTime;
    }
  }

  // --- REPLACE THE OLD METHOD ---
  void _onToggleTaskCompletion(
    ToggleTaskCompletion event,
    Emitter<TasksState> emit,
  ) async {
    try {
      // 1. First, update the task as requested
      await database.updateTaskCompletion(event.taskId, event.isCompleted);

      // 2. Check if we just completed a recurring task
      if (event.isCompleted == true) {
        // Get the full task data
        final task = await database.getTaskById(
          event.taskId,
        ); // <-- We'll add this method

        if (task != null && task.isRecurring && task.dueDate != null) {
          // 3. Calculate the next due date
          final nextDueDate = _calculateNextDueDate(
            task.dueDate!,
            task.frequency!,
          );

          // 4. Create a new task (a copy of the old one)
          final newTask = TasksCompanion(
            title: drift.Value(task.title),
            note: drift.Value(task.note),
            priority: drift.Value(task.priority),
            categoryId: drift.Value(task.categoryId),
            isRecurring: drift.Value(true),
            frequency: drift.Value(task.frequency),
            dueDate: drift.Value(nextDueDate), // Set the new due date
            isCompleted: drift.Value(false), // Reset completion
          );

          // 5. Add the new task to the database
          await database.addTask(newTask);
          // The stream will see this new task and update the UI!
        }
      }
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
  // --- END OF REPLACEMENT ---

  // Handles deleting a task
  void _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    try {
      await database.deleteTaskById(event.taskId);
      // The stream will update automatically.
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void _onEditTask(EditTask event, Emitter<TasksState> emit) async {
    try {
      await database.updateTask(event.taskId, event.task);
      // The stream will see the change and update the UI automatically
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void _onClearCompletedTasks(
    ClearCompletedTasks event,
    Emitter<TasksState> emit,
  ) async {
    try {
      await database.clearCompletedTasks();
      // The stream will see the changes and update the UI automatically
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
