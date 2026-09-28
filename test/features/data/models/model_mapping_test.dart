import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/habits/data/models/habit_model.dart';
import 'package:corelog/features/habits/data/models/habit_occurrence_model.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:corelog/features/tasks/data/models/task_model.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/projects/data/models/project_model.dart';
import 'package:corelog/features/projects/domain/entities/project_status.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('ProjectModel', () {
    test('fromData converts Drift project row into ProjectModel', () async {
      final now = DateTime(2026, 1, 1);

      await database.into(database.projects).insert(
            ProjectsCompanion.insert(
              name: 'CoreLog',
              description: const Value('Productivity app'),
              status: const Value('active'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final data = await database.select(database.projects).getSingle();
      final model = ProjectModel.fromData(data);

      expect(model.id, data.id);
      expect(model.name, 'CoreLog');
      expect(model.description, 'Productivity app');
      expect(model.status, ProjectStatus.active);
      expect(model.createdAt, now);
      expect(model.updatedAt, now);
    });

    test('toCompanion converts ProjectModel into Drift companion', () {
      final now = DateTime(2026, 1, 1);

      final model = ProjectModel(
        id: 1,
        name: 'CoreLog',
        description: 'Productivity app',
        status: ProjectStatus.completed,
        createdAt: now,
        updatedAt: now,
      );

      final companion = model.toCompanion();

      expect(companion.name.value, 'CoreLog');
      expect(companion.description.value, 'Productivity app');
      expect(companion.status.value, 'completed');
      expect(companion.createdAt.value, now);
      expect(companion.updatedAt.value, now);
    });
  });

  group('TaskModel', () {
    test('fromData converts Drift task row into TaskModel', () async {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);
      final dueDate = DateTime(2026, 1, 10);
      final completedAt = DateTime(2026, 1, 11);

      await database.into(database.tasks).insert(
            TasksCompanion.insert(
              activityId: const Value(1),
              title: 'Build Task Model',
              description: const Value('Create and test the task model'),
              status: 'inProgress',
              dueDate: Value(dueDate),
              completedAt: Value(completedAt),
              createdAt: createdAt,
              updatedAt: updatedAt,
            ),
          );

      final data = await database.select(database.tasks).getSingle();
      final model = TaskModel.fromData(data);

      expect(model.id, data.id);
      expect(model.activityId, 1);
      expect(model.title, 'Build Task Model');
      expect(model.description, 'Create and test the task model');
      expect(model.status, TaskStatus.inProgress);
      expect(model.dueDate, dueDate);
      expect(model.completedAt, completedAt);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test('toCompanion converts TaskModel into Drift companion', () {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);
      final dueDate = DateTime(2026, 1, 10);
      final completedAt = DateTime(2026, 1, 11);

      final model = TaskModel(
        id: 1,
        activityId: 2,
        title: 'Build Task Model',
        description: 'Create and test the task model',
        status: TaskStatus.completed,
        dueDate: dueDate,
        completedAt: completedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final companion = model.toCompanion();

      expect(companion.activityId.value, 2);
      expect(companion.title.value, 'Build Task Model');
      expect(companion.description.value, 'Create and test the task model');
      expect(companion.status.value, 'completed');
      expect(companion.dueDate.value, dueDate);
      expect(companion.completedAt.value, completedAt);
      expect(companion.createdAt.value, createdAt);
      expect(companion.updatedAt.value, updatedAt);
    });

    test('toCompanion preserves nullable task fields', () {
      final now = DateTime(2026, 1, 1);

      final model = TaskModel(
        id: 1,
        title: 'Unassigned task',
        status: TaskStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      final companion = model.toCompanion();

      expect(companion.activityId.value, isNull);
      expect(companion.description.value, isNull);
      expect(companion.dueDate.value, isNull);
      expect(companion.completedAt.value, isNull);
    });
  });

  group('HabitModel', () {
    test('fromData converts Drift habit row into HabitModel', () async {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);
      final targetTime = DateTime(2026, 1, 1, 7, 30);

      await database.into(database.habits).insert(
            HabitsCompanion.insert(
              projectId: const Value(1),
              name: 'Morning planning',
              description: const Value('Plan the day'),
              weekdayMask: 31,
              targetTime: Value(targetTime),
              targetDurationMinutes: const Value(60),
              isActive: const Value(true),
              createdAt: createdAt,
              updatedAt: updatedAt,
            ),
          );

      final data = await database.select(database.habits).getSingle();
      final model = HabitModel.fromData(data);

      expect(model.id, data.id);
      expect(model.projectId, 1);
      expect(model.name, 'Morning planning');
      expect(model.description, 'Plan the day');
      expect(model.weekdayMask, 31);
      expect(model.targetTime, targetTime);
      expect(model.targetDuration, const Duration(hours: 1));
      expect(model.isActive, isTrue);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test('toCompanion converts HabitModel into Drift companion', () {
      final now = DateTime(2026, 1, 1);
      final targetTime = DateTime(2026, 1, 1, 7, 30);

      final model = HabitModel(
        id: 1,
        projectId: 2,
        name: 'Morning planning',
        description: 'Plan the day',
        weekdayMask: 31,
        targetTime: targetTime,
        targetDuration: const Duration(minutes: 30),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final companion = model.toCompanion();

      expect(companion.projectId.value, 2);
      expect(companion.name.value, 'Morning planning');
      expect(companion.description.value, 'Plan the day');
      expect(companion.weekdayMask.value, 31);
      expect(companion.targetTime.value, targetTime);
      expect(companion.targetDurationMinutes.value, 30);
      expect(companion.isActive.value, isTrue);
      expect(companion.createdAt.value, now);
      expect(companion.updatedAt.value, now);
    });

    test('toCompanion preserves nullable habit fields', () {
      final now = DateTime(2026, 1, 1);

      final model = HabitModel(
        id: 1,
        name: 'Unscheduled habit',
        weekdayMask: 127,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final companion = model.toCompanion();

      expect(companion.projectId.value, isNull);
      expect(companion.description.value, isNull);
      expect(companion.targetTime.value, isNull);
      expect(companion.targetDurationMinutes.value, isNull);
    });
  });

  group('HabitOccurrenceModel', () {
    test(
      'fromData converts Drift habit occurrence row into HabitOccurrenceModel',
      () async {
        final scheduledDate = DateTime(2026, 1, 5);
        final completedAt = DateTime(2026, 1, 5, 8);
        final createdAt = DateTime(2026, 1, 1);

        await database.into(database.habitOccurrences).insert(
              HabitOccurrencesCompanion.insert(
                habitId: 1,
                scheduledDate: scheduledDate,
                completedAt: Value(completedAt),
                status: 'completed',
                createdAt: createdAt,
              ),
            );

        final data =
            await database.select(database.habitOccurrences).getSingle();
        final model = HabitOccurrenceModel.fromData(data);

        expect(model.id, data.id);
        expect(model.habitId, 1);
        expect(model.scheduledDate, scheduledDate);
        expect(model.completedAt, completedAt);
        expect(model.status, HabitOccurrenceStatus.completed);
        expect(model.createdAt, createdAt);
      },
    );

    test(
      'toCompanion converts HabitOccurrenceModel into Drift companion',
      () {
        final scheduledDate = DateTime(2026, 1, 5);
        final completedAt = DateTime(2026, 1, 5, 8);
        final createdAt = DateTime(2026, 1, 1);

        final model = HabitOccurrenceModel(
          id: 1,
          habitId: 2,
          scheduledDate: scheduledDate,
          completedAt: completedAt,
          status: HabitOccurrenceStatus.skipped,
          createdAt: createdAt,
        );

        final companion = model.toCompanion();

        expect(companion.habitId.value, 2);
        expect(companion.scheduledDate.value, scheduledDate);
        expect(companion.completedAt.value, completedAt);
        expect(companion.status.value, 'skipped');
        expect(companion.createdAt.value, createdAt);
      },
    );
  });
}