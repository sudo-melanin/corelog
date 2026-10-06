// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/get_today_tasks.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late GetTodayTasks getTodayTasks;

  final now = DateTime(2026, 9, 29, 14);

  setUp(() {
    repository = MockTaskRepository();
    getTodayTasks = GetTodayTasks(repository);
  });

  Task createTask({
    required int id,
    required String title,
    TaskStatus status = TaskStatus.pending,
    DateTime? plannedStart,
    DateTime? plannedEnd,
  }) {
    return Task(
      id: id,
      title: title,
      status: status,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      createdAt: DateTime(2026, 9, 29),
      updatedAt: DateTime(2026, 9, 29),
    );
  }

  test('returns scheduled tasks that overlap today', () async {
    final todayTask = createTask(
      id: 1,
      title: 'Flutter development',
      plannedStart: DateTime(2026, 9, 29, 13),
      plannedEnd: DateTime(2026, 9, 29, 15),
    );

    final yesterdayTask = createTask(
      id: 2,
      title: 'Yesterday task',
      plannedStart: DateTime(2026, 9, 28, 13),
      plannedEnd: DateTime(2026, 9, 28, 15),
    );

    final tomorrowTask = createTask(
      id: 3,
      title: 'Tomorrow task',
      plannedStart: DateTime(2026, 9, 30, 13),
      plannedEnd: DateTime(2026, 9, 30, 15),
    );

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Right([
        todayTask,
        yesterdayTask,
        tomorrowTask,
      ]),
    );

    final result = await getTodayTasks(now);

    expect(result.isRight(), isTrue);

    final tasks = result.getOrElse(
      (_) => throw StateError('Expected task retrieval to succeed.'),
    );

    expect(tasks, hasLength(1));
    expect(tasks.single.id, todayTask.id);
  });

  test('includes a task that started yesterday and ends today', () async {
    final overnightTask = createTask(
      id: 1,
      title: 'Overnight task',
      plannedStart: DateTime(2026, 9, 28, 23),
      plannedEnd: DateTime(2026, 9, 29, 1),
    );

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Right([overnightTask]),
    );

    final result = await getTodayTasks(now);

    expect(result.isRight(), isTrue);

    final tasks = result.getOrElse(
      (_) => throw StateError('Expected task retrieval to succeed.'),
    );

    expect(tasks, hasLength(1));
    expect(tasks.single.id, overnightTask.id);
  });

  test('includes a task that starts today and ends tomorrow', () async {
    final overnightTask = createTask(
      id: 1,
      title: 'Overnight task',
      plannedStart: DateTime(2026, 9, 29, 23),
      plannedEnd: DateTime(2026, 9, 30, 1),
    );

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Right([overnightTask]),
    );

    final result = await getTodayTasks(now);

    expect(result.isRight(), isTrue);

    final tasks = result.getOrElse(
      (_) => throw StateError('Expected task retrieval to succeed.'),
    );

    expect(tasks, hasLength(1));
    expect(tasks.single.id, overnightTask.id);
  });

  test('includes in-progress and paused tasks regardless of schedule', () async {
    final inProgressTask = createTask(
      id: 1,
      title: 'In progress',
      status: TaskStatus.inProgress,
      plannedStart: DateTime(2026, 9, 28, 10),
      plannedEnd: DateTime(2026, 9, 28, 11),
    );

    final pausedTask = createTask(
      id: 2,
      title: 'Paused',
      status: TaskStatus.paused,
      plannedStart: DateTime(2026, 9, 28, 12),
      plannedEnd: DateTime(2026, 9, 28, 13),
    );

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Right([
        inProgressTask,
        pausedTask,
      ]),
    );

    final result = await getTodayTasks(now);

    expect(result.isRight(), isTrue);

    final tasks = result.getOrElse(
      (_) => throw StateError('Expected task retrieval to succeed.'),
    );

    expect(tasks, hasLength(2));
    expect(
      tasks.map((task) => task.id),
      containsAll([inProgressTask.id, pausedTask.id]),
    );
  });

  test('includes unscheduled pending tasks', () async {
    final task = createTask(
      id: 1,
      title: 'Unscheduled task',
    );

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Right([task]),
    );

    final result = await getTodayTasks(now);

    expect(result.isRight(), isTrue);

    final tasks = result.getOrElse(
      (_) => throw StateError('Expected task retrieval to succeed.'),
    );

    expect(tasks, hasLength(1));
    expect(tasks.single.id, task.id);
  });

  test('excludes completed and skipped tasks', () async {
    final completedTask = createTask(
      id: 1,
      title: 'Completed',
      status: TaskStatus.completed,
      plannedStart: DateTime(2026, 9, 29, 13),
      plannedEnd: DateTime(2026, 9, 29, 15),
    );

    final skippedTask = createTask(
      id: 2,
      title: 'Skipped',
      status: TaskStatus.skipped,
      plannedStart: DateTime(2026, 9, 29, 13),
      plannedEnd: DateTime(2026, 9, 29, 15),
    );

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Right([
        completedTask,
        skippedTask,
      ]),
    );

    final result = await getTodayTasks(now);

    expect(result.isRight(), isTrue);

    final tasks = result.getOrElse(
      (_) => throw StateError('Expected task retrieval to succeed.'),
    );

    expect(tasks, isEmpty);
  });

  test('propagates repository failure', () async {
    final failure = DatabaseFailure('Failed to load tasks.');

    when(() => repository.getTasks()).thenAnswer(
      (_) async => Left(failure),
    );

    final result = await getTodayTasks(now);

    expect(result, Left(failure));
  });
}