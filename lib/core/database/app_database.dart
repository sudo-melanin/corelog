import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/habit_occurrences.dart';
import 'tables/habits.dart';
import 'tables/projects.dart';
import 'tables/tasks.dart';
import 'tables/time_blocks.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    Tasks,
    TimeBlocks,
    Habits,
    HabitOccurrences,
  ]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'corelog');
}
