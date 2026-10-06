import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/habit_occurrences.dart';
import 'tables/habits.dart';
import 'tables/projects.dart';
import 'tables/tasks.dart';
import 'tables/activities.dart';
import 'tables/task_execution_sessions.dart';
import 'tables/activity_history.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Projects, Tasks, Habits, HabitOccurrences, Activities,TaskExecutionSessions, ActivityHistory,])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 14;

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

      if (from < 10) {
        await m.addColumn(tasks, tasks.plannedStart);
        await m.addColumn(tasks, tasks.plannedEnd);
      }

      if (from < 11) {
        await m.createTable(taskExecutionSessions);
      }

      if (from < 12) {
        await m.addColumn(tasks, tasks.skippedAt);
        await m.addColumn(tasks, tasks.skipReason);
        await m.addColumn(tasks, tasks.skipNote);
      }

      if (from < 13) {
        await m.createTable(activityHistory);
      }

      if (from < 14) {
        await customStatement('''
          CREATE TABLE activity_history_new (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            activity_id INTEGER,
            task_title TEXT NOT NULL,
            planned_start INTEGER,
            planned_end INTEGER,
            outcome TEXT NOT NULL,
            occurred_at INTEGER NOT NULL,
            actual_duration_minutes INTEGER NOT NULL,
            skip_reason TEXT,
            skip_note TEXT
          )
        ''');

        await customStatement('''
          INSERT INTO activity_history_new (
            id,
            task_id,
            activity_id,
            task_title,
            planned_start,
            planned_end,
            outcome,
            occurred_at,
            actual_duration_minutes,
            skip_reason,
            skip_note
          )
          SELECT
            id,
            task_id,
            activity_id,
            task_title,
            planned_start,
            planned_end,
            'completed',
            completed_at,
            actual_duration_minutes,
            NULL,
            NULL
          FROM activity_history
        ''');

        await customStatement(
          'DROP TABLE activity_history',
        );

        await customStatement(
          'ALTER TABLE activity_history_new RENAME TO activity_history',
        );
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'corelog');
}
