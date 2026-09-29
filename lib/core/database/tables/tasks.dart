import 'package:corelog/core/core.dart';
import 'package:drift/drift.dart';
import 'activities.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get activityId => integer().nullable().references(Activities, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get plannedStart => dateTime().nullable()();
  DateTimeColumn get plannedEnd => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get skippedAt => dateTime().nullable()();
  TextColumn get skipReason => text().nullable()();
  TextColumn get skipNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

}
