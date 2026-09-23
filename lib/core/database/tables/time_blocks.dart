import 'package:drift/drift.dart';
import 'projects.dart';
import 'tasks.dart';

class TimeBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  DateTimeColumn get plannedStart => dateTime()();
  DateTimeColumn get plannedEnd => dateTime()();
  DateTimeColumn get actualStart => dateTime().nullable()();
  DateTimeColumn get actualEnd => dateTime().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
