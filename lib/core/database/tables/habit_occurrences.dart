import 'package:drift/drift.dart';
import 'habits.dart';

class HabitOccurrences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get scheduledDate => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
}
