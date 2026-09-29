import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:corelog/features/activities/domain/entities/activity.dart';
import 'package:corelog/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';

void main() {
  late db.AppDatabase database;
  late TaskRepositoryImpl repository;
  late ActivityRepositoryImpl activityRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = TaskRepositoryImpl(database);
    activityRepository = ActivityRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<Activity> createActivity({
  String name = 'Flutter Development',
}) async {
  final now = DateTime(2026, 1, 1, 10);

  final result = await activityRepository.createActivity(
    Activity(
      id: 0,
      name: name,
      description: '$name activity',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
  );

  return result.match(
    (failure) => throw TestFailure(failure.message),
    (activity) => activity,
  );
}

Task createTask({
  required int activityId,
  String title = 'Build task repository',
  TaskStatus status = TaskStatus.pending,
  DateTime? skippedAt,
  TaskSkipReason? skipReason,
  String? skipNote,
}) {
  final now = DateTime(2026, 1, 1, 10);

  return Task(
    id: 0,
    activityId: activityId,
    title: title,
    description: 'Repository test task',
    status: status,
    dueDate: DateTime(2026, 1, 2, 10),
    plannedStart: DateTime(2026, 1, 1, 14),
    plannedEnd: DateTime(2026, 1, 1, 15, 30),
    completedAt: null,
    createdAt: now,
    updatedAt: now,
    skippedAt: skippedAt,
    skipReason: skipReason,
    skipNote: skipNote,
  );
}

  test('createTask creates and returns a task', () async {
    final activity = await createActivity();

    final result = await repository.createTask(
      createTask(activityId: activity.id)
    );

    result.match(
      (failure) => fail(failure.message),
      (task) {
        expect(task.id, greaterThan(0));
        expect(task.activityId, activity.id);
        expect(task.title, 'Build task repository');
        expect(task.status, TaskStatus.pending);
        expect(task.plannedStart, DateTime(2026, 1, 1, 14));
        expect(task.plannedEnd, DateTime(2026, 1, 1, 15, 30));
        expect(task.skippedAt, isNull); expect(task.skipReason, isNull); expect(task.skipNote, isNull);
        
      },
    );
  });

  test('getTaskById returns the task when it exists', () async {
    final activity = await createActivity();

    final created = await repository.createTask(
      createTask(activityId: activity.id),
    );

    final task = created.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );

    final result = await repository.getTaskById(task.id);

    result.match(
      (failure) => fail(failure.message),
      (found) {
        expect(found, isNotNull);
        expect(found!.id, task.id);
        expect(found.title, task.title);
      },
    );
  });

  test('getTaskById returns null when the task does not exist', () async {
    final result = await repository.getTaskById(999);

    result.match(
      (failure) => fail(failure.message),
      (task) => expect(task, isNull),
    );
  });

  test('getTasks returns all tasks', () async {
    final activity = await createActivity();

    await repository.createTask(
      createTask(
        activityId: activity.id,
        title: 'Task one',
      ),
    );

    await repository.createTask(
      createTask(
        activityId: activity.id,
        title: 'Task two',
      ),
    );

    final result = await repository.getTasks();

    result.match(
      (failure) => fail(failure.message),
      (tasks) {
        expect(tasks, hasLength(2));
        expect(tasks.map((task) => task.title), containsAll([
          'Task one',
          'Task two',
        ]));
      },
    );
  });

  test('getTasksByActivity returns only tasks for the requested activity',
      () async {
    final firstActivity = await createActivity(
      name: 'Flutter Development',
    );

     final secondActivity = await createActivity(
    name: 'Fitness',
  );

    await repository.createTask(
      createTask(
      activityId: firstActivity.id,
      title: 'Build Corelog feature',
      )
    );


    await repository.createTask(
      createTask(
        activityId: secondActivity.id,
        title: 'First project task',
      ),
    );

    final result =
    await repository.getTasksByActivity(firstActivity.id);

    result.match(
      (failure) => fail(failure.message),
      (tasks) {
        expect(tasks, hasLength(1));
        expect(tasks.first.title, 'Build Corelog feature');
        expect(tasks.first.activityId, firstActivity.id);
      },
    );
  });

  test('updateTask updates and returns the task', () async {
    final activity = await createActivity();

    final created = await repository.createTask(
      createTask(activityId: activity.id),
    );

    final task = created.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );

    final updatedTask = Task(
      id: task.id,
      activityId: task.activityId,
      title: 'Updated task',
      description: 'Updated description',
      status: TaskStatus.inProgress,
      dueDate: DateTime(2026, 1, 3, 10),
      completedAt: null,
      createdAt: task.createdAt,
      updatedAt: DateTime(2026, 1, 2, 10),
      plannedStart: DateTime(2026, 1, 3, 9),
      plannedEnd: DateTime(2026, 1, 3, 10, 30),
    );

    final result = await repository.updateTask(updatedTask);

    result.match(
      (failure) => fail(failure.message),
      (updated) {
        expect(updated.id, task.id);
        expect(updated.title, 'Updated task');
        expect(updated.status, TaskStatus.inProgress);
        expect(updated.description, 'Updated description');
        expect(updated.plannedStart, DateTime(2026, 1, 3, 9));
        expect(updated.plannedEnd, DateTime(2026, 1, 3, 10, 30));
      },
    );
  });

  test('updateTask returns failure when task does not exist', () async {
    final result = await repository.updateTask(
      Task(
        id: 999,
        activityId: null,
        title: 'Missing task',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      ),
    );

    result.match(
      (failure) => expect(failure.message, 'Task not found.'),
      (_) => fail('Expected updateTask to fail.'),
    );
  });

  test('deleteTask deletes an existing task', () async {
    final activity = await createActivity();

    final created = await repository.createTask(
      createTask(activityId: activity.id),
    );

    final task = created.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );

    final result = await repository.deleteTask(task.id);

    result.match(
      (failure) => fail(failure.message),
      (_) {},
    );

    final lookup = await repository.getTaskById(task.id);

    lookup.match(
      (failure) => fail(failure.message),
      (found) => expect(found, isNull),
    );
  });

  test('deleteTask returns failure when task does not exist', () async {
    final result = await repository.deleteTask(999);

    result.match(
      (failure) => expect(failure.message, 'Task not found.'),
      (_) => fail('Expected deleteTask to fail.'),
    );
  });

  test('createTask supports an unscheduled task', () async {
  final result = await repository.createTask(
    Task(
      id: 0,
      title: 'Unscheduled task',
      status: TaskStatus.pending,
      createdAt: DateTime(2026, 1, 1, 10),
      updatedAt: DateTime(2026, 1, 1, 10),
    ),
  );

  result.match(
    (failure) => fail(failure.message),
    (task) {
      expect(task.id, greaterThan(0));
      expect(task.plannedStart, isNull);
      expect(task.plannedEnd, isNull);
    },
  );
});
}