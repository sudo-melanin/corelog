import 'package:drift/drift.dart';
import 'projects.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get weekdayMask => integer()();
  DateTimeColumn get targetTime => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
