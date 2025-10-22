import 'package:drift/drift.dart';

// --- CATEGORIES TABLE ---
// This table will store our categories like "Work", "Home", etc.
@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();

  // We can add a color for each category later if we want
  // IntColumn get color => integer().withDefault(const Constant(0xFFFFFFFF))();
}

// --- TASKS TABLE ---
// This is our main table for tasks
@DataClassName('Task')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get note => text().nullable()(); // The optional note

  DateTimeColumn get dueDate => dateTime().nullable()(); // Optional deadline
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  // 1 = Low, 2 = Medium, 3 = High
  IntColumn get priority => integer().withDefault(const Constant(1))();

  // Foreign Key: Links a task to a category
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  // Recurring options
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  // e.g., "daily", "weekly", "monthly"
  TextColumn get frequency => text().nullable()();
}
