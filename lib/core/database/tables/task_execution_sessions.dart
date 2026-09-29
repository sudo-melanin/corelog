import 'package:drift/drift.dart';

import 'tasks.dart';

class TaskExecutionSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get taskId => integer().references(Tasks, #id)();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get endedAt => dateTime().nullable()();
}