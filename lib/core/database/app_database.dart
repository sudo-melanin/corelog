import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/habit_occurrences.dart';
import 'tables/habits.dart';
import 'tables/projects.dart';
import 'tables/tasks.dart';
import 'tables/time_blocks.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Projects, Tasks, TimeBlocks, Habits, HabitOccurrences])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(projects, projects.status);
      }
      if (from < 3) {
        await m.addColumn(habits, habits.targetDurationMinutes);
      }

      if (from < 4) {
        await m.deleteTable('timeBlocks');
        await m.createTable(timeBlocks);
      }

      if (from < 5) {
        await m.addColumn(timeBlocks, timeBlocks.description);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'corelog');
}
