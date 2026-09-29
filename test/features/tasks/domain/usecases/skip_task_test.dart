import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/skip_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late SkipTask skipTask;

  setUpAll(() {
    registerFallbackValue(
      Task(
        id: 0,
        title: 'Fallback task',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    taskRepository = MockTaskRepository();
    skipTask = SkipTask(taskRepository);
  });

  Task buildTask({
    int id = 1,
    TaskStatus status = TaskStatus.pending,
    int? activityId,
    String title = 'Test task',
    String? description = 'Test description',
    DateTime? dueDate,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    DateTime? completedAt,
    DateTime? skippedAt,
    TaskSkipReason? skipReason,
    String? skipNote,
  }) {
    final now = DateTime(2026, 1, 1, 10);

    return Task(
      id: id,
      activityId: activityId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      completedAt: completedAt,
      skippedAt: skippedAt,
      skipReason: skipReason,
      skipNote: skipNote,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('SkipTask', () {
    test(
      'skips pending task and records reason, note, and timestamp',
      () async {
        final task = buildTask(
          status: TaskStatus.pending,
          plannedStart: DateTime(2026, 1, 12, 14),
          plannedEnd: DateTime(2026, 1, 12, 15),
        );

        when(() => taskRepository.updateTask(any()))
            .thenAnswer((invocation) async {
          final skippedTask =
              invocation.positionalArguments.first as Task;

          return Right(skippedTask);
        });

        final result = await skipTask(
          task: task,
          reason: TaskSkipReason.higherPriorityCameUp,
          note: 'Urgent work came up',
        );

        expect(result.isRight(), isTrue);

        final skippedTask = result.getOrElse(
          (_) => throw StateError('Expected skip to succeed.'),
        );

        expect(skippedTask.status, TaskStatus.skipped);
        expect(skippedTask.skippedAt, isNotNull);
        expect(
          skippedTask.skipReason,
          TaskSkipReason.higherPriorityCameUp,
        );
        expect(skippedTask.skipNote, 'Urgent work came up');
        expect(skippedTask.plannedStart, task.plannedStart);
        expect(skippedTask.plannedEnd, task.plannedEnd);

        verify(
          () => taskRepository.updateTask(any()),
        ).called(1);
      },
    );

    test('skips pending task without a note', () async {
      final task = buildTask(
        status: TaskStatus.pending,
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((invocation) async {
        final skippedTask =
            invocation.positionalArguments.first as Task;

        return Right(skippedTask);
      });

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.notEnoughTime,
      );

      expect(result.isRight(), isTrue);

      final skippedTask = result.getOrElse(
        (_) => throw StateError('Expected skip to succeed.'),
      );

      expect(skippedTask.status, TaskStatus.skipped);
      expect(skippedTask.skipReason, TaskSkipReason.notEnoughTime);
      expect(skippedTask.skipNote, isNull);
      expect(skippedTask.skippedAt, isNotNull);

      verify(
        () => taskRepository.updateTask(any()),
      ).called(1);
    });

    test('rejects in-progress task', () async {
      final task = buildTask(
        status: TaskStatus.inProgress,
      );

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.lostFocus,
      );

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('rejects paused task', () async {
      final task = buildTask(
        status: TaskStatus.paused,
      );

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.lostFocus,
      );

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('rejects completed task', () async {
      final task = buildTask(
        status: TaskStatus.completed,
      );

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.other,
      );

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('rejects already skipped task', () async {
      final task = buildTask(
        status: TaskStatus.skipped,
      );

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.other,
      );

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('propagates task repository failure', () async {
      final task = buildTask(
        status: TaskStatus.pending,
      );

      const failure = DatabaseFailure(
        'Failed to update task.',
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.other,
      );

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(
        () => taskRepository.updateTask(any()),
      ).called(1);
    });
  });
}