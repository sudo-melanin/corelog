import 'package:drift/drift.dart';

import 'activities.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get activityId => integer().nullable().references(Activities, #id)();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  IntColumn get weekdayMask => integer()();

  DateTimeColumn get targetTime => dateTime().nullable()();

  IntColumn get targetDurationMinutes => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
