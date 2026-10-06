import 'package:drift/drift.dart';

class ActivityHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Historical reference only. Not a foreign key.
  IntColumn get taskId => integer()();

  /// Historical reference only. Not a foreign key.
  IntColumn get activityId => integer().nullable()();

  /// Snapshot of the task title at the time of the outcome.
  TextColumn get taskTitle => text()();

  DateTimeColumn get plannedStart => dateTime().nullable()();

  DateTimeColumn get plannedEnd => dateTime().nullable()();

  /// completed / skipped
  TextColumn get outcome => text()();

  /// Completion time or skip time.
  DateTimeColumn get occurredAt => dateTime()();

  /// Stored as minutes.
  IntColumn get actualDurationMinutes => integer()();

  /// Stored as the enum name when the outcome is skipped.
  TextColumn get skipReason => text().nullable()();

  TextColumn get skipNote => text().nullable()();
}