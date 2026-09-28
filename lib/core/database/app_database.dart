import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/habit_occurrences.dart';
import 'tables/habits.dart';
import 'tables/projects.dart';
import 'tables/tasks.dart';
import 'tables/activities.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Projects, Tasks, Habits, HabitOccurrences, Activities,])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

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

      if (from < 6) {
        await m.createTable(activities);
      }

      if (from < 7) {
        await m.addColumn(tasks, tasks.activityId);
      }

      if (from < 8) {
        await m.deleteTable('time_blocks');
      }

      if (from < 9) {
        await m.renameColumn(habits, 'project_id', habits.activityId);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'corelog');
}
