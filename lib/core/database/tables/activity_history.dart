import 'package:drift/drift.dart';

class ActivityHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Historical reference only. Not a foreign key.
  IntColumn get taskId => integer()();

  /// Historical reference only. Not a foreign key.
  IntColumn get activityId => integer().nullable()();

  /// Snapshot of the task title at completion time.
  TextColumn get taskTitle => text()();

  DateTimeColumn get plannedStart => dateTime().nullable()();

  DateTimeColumn get plannedEnd => dateTime().nullable()();

  DateTimeColumn get completedAt => dateTime()();

  /// Stored as minutes to keep the database representation simple.
  IntColumn get actualDurationMinutes => integer()();
}