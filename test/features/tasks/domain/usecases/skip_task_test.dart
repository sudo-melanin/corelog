import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/skip_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockActivityHistoryRepository extends Mock
    implements ActivityHistoryRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late MockActivityHistoryRepository historyRepository;
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

    registerFallbackValue(
      ActivityHistory(
        id: 0,
        taskId: 0,
        taskTitle: 'Fallback task',
        outcome: HistoryOutcome.skipped,
        occurredAt: DateTime(2026, 1, 1),
        actualDuration: Duration.zero,
        skipReason: TaskSkipReason.other,
      ),
    );
  });

  setUp(() {
    taskRepository = MockTaskRepository();
    historyRepository = MockActivityHistoryRepository();

    skipTask = SkipTask(
      taskRepository: taskRepository,
      historyRepository: historyRepository,
    );
  });

  Task buildTask({
    int id = 1,
    TaskStatus status = TaskStatus.pending,
    int? activityId,
    String title = 'Test task',
    DateTime? plannedStart,
    DateTime? plannedEnd,
  }) {
    final now = DateTime(2026, 1, 1, 10);

    return Task(
      id: id,
      activityId: activityId,
      title: title,
      status: status,
      createdAt: now,
      updatedAt: now,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
    );
  }

  group('SkipTask', () {
    test(
      'skips pending task and creates skipped history',
      () async {
        final task = buildTask(
          activityId: 10,
          title: 'Flutter development',
          plannedStart: DateTime(2026, 1, 1, 14),
          plannedEnd: DateTime(2026, 1, 1, 15),
        );

        when(() => taskRepository.updateTask(any()))
            .thenAnswer((invocation) async {
          return Right(
            invocation.positionalArguments.first as Task,
          );
        });

        when(() => historyRepository.createHistory(any()))
            .thenAnswer((invocation) async {
          return Right(
            invocation.positionalArguments.first as ActivityHistory,
          );
        });

        final result = await skipTask(
          task: task,
          reason: TaskSkipReason.higherPriorityCameUp,
          note: 'Production issue came up.',
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
        expect(skippedTask.skipNote, 'Production issue came up.');

        final captured = verify(
          () => historyRepository.createHistory(captureAny()),
        ).captured.single as ActivityHistory;

        expect(captured.taskId, task.id);
        expect(captured.activityId, task.activityId);
        expect(captured.taskTitle, task.title);
        expect(captured.plannedStart, task.plannedStart);
        expect(captured.plannedEnd, task.plannedEnd);
        expect(captured.outcome, HistoryOutcome.skipped);
        expect(captured.occurredAt, skippedTask.skippedAt);
        expect(captured.actualDuration, Duration.zero);
        expect(
          captured.skipReason,
          TaskSkipReason.higherPriorityCameUp,
        );
        expect(captured.skipNote, 'Production issue came up.');
      },
    );

    test('rejects in-progress task', () async {
      final task = buildTask(
        status: TaskStatus.inProgress,
      );

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.other,
      );

      expect(result.isLeft(), isTrue);

      verifyNever(() => taskRepository.updateTask(any()));
      verifyNever(() => historyRepository.createHistory(any()));
    });

    test('rejects paused task', () async {
      final task = buildTask(
        status: TaskStatus.paused,
      );

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.other,
      );

      expect(result.isLeft(), isTrue);

      verifyNever(() => taskRepository.updateTask(any()));
      verifyNever(() => historyRepository.createHistory(any()));
    });

    test('propagates task update failure', () async {
      final task = buildTask();

      const failure = DatabaseFailure(
        'Failed to update task.',
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.notEnoughTime,
      );

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(() => taskRepository.updateTask(any())).called(1);
      verifyNever(() => historyRepository.createHistory(any()));
    });

    test('propagates history creation failure', () async {
      final task = buildTask();

      const failure = DatabaseFailure(
        'Failed to create history.',
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((invocation) async {
        return Right(
          invocation.positionalArguments.first as Task,
        );
      });

      when(() => historyRepository.createHistory(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await skipTask(
        task: task,
        reason: TaskSkipReason.other,
      );

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(() => taskRepository.updateTask(any())).called(1);
      verify(() => historyRepository.createHistory(any())).called(1);
    });
  });
}