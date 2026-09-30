import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/calculate_task_actual_duration.dart';
import 'package:corelog/features/tasks/domain/usecases/complete_task.dart';

class MockActivityHistoryRepository extends Mock
    implements ActivityHistoryRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockTaskExecutionSessionRepository extends Mock
    implements TaskExecutionSessionRepository {}

class MockCalculateTaskActualDuration extends Mock
    implements CalculateTaskActualDuration {}

void main() {
  late MockTaskRepository taskRepository;
  late MockTaskExecutionSessionRepository sessionRepository;
  late MockActivityHistoryRepository historyRepository;
  late MockCalculateTaskActualDuration calculateActualDuration;
  late CompleteTask completeTask;

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
      TaskExecutionSession(
        id: 0,
        taskId: 0,
        startedAt: DateTime(2026, 1, 1),
      ),
    );

    registerFallbackValue(
      ActivityHistory(
        id: 0,
        taskId: 0,
        taskTitle: 'Fallback task',
        completedAt: DateTime(2026, 1, 1),
        actualDuration: Duration.zero,
      ),
    );
  });

  setUp(() {
    taskRepository = MockTaskRepository();
    sessionRepository = MockTaskExecutionSessionRepository();
    historyRepository = MockActivityHistoryRepository();
    calculateActualDuration = MockCalculateTaskActualDuration();

    completeTask = CompleteTask(
      taskRepository: taskRepository,
      sessionRepository: sessionRepository,
      historyRepository: historyRepository,
      calculateActualDuration: calculateActualDuration.call,
    );
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

  group('CompleteTask', () {
    test(
      'completes unscheduled pending task without an execution session',
      () async {
        final task = buildTask(
          status: TaskStatus.pending,
        );

        when(() => taskRepository.updateTask(any()))
            .thenAnswer((invocation) async {
          return Right(invocation.positionalArguments.first as Task);
        });

        when(() => historyRepository.createHistory(any()))
          .thenAnswer((invocation) async {
          return Right(
          invocation.positionalArguments.first as ActivityHistory,
          );
          });

        final result = await completeTask(task);

        expect(result.isRight(), isTrue);

        final completedTask = result.getOrElse(
          (_) => throw StateError('Expected completion to succeed.'),
        );

        expect(completedTask.status, TaskStatus.completed);
        expect(completedTask.completedAt, isNotNull);
        expect(completedTask.plannedStart, isNull);
        expect(completedTask.plannedEnd, isNull);

        verify(() => taskRepository.updateTask(any())).called(1);
        verifyNever(
          () => sessionRepository.getActiveSession(any()),
        );
      },
    );

    test(
      'completes in-progress task and ends active session',
      () async {
        final task = buildTask(
          status: TaskStatus.inProgress,
          plannedStart: DateTime(2026, 1, 12, 14),
          plannedEnd: DateTime(2026, 1, 12, 15),
        );

        final activeSession = TaskExecutionSession(
          id: 1,
          taskId: task.id,
          startedAt: DateTime(2026, 1, 12, 14, 5),
        );

        when(() => sessionRepository.getActiveSession(task.id))
            .thenAnswer((_) async => Right(activeSession));

        when(() => sessionRepository.endSession(any()))
            .thenAnswer((invocation) async {
          final session =
              invocation.positionalArguments.first as TaskExecutionSession;

          return Right(session);
        });

        when(() => calculateActualDuration(task.id)).thenAnswer(
          (_) async => const Right(Duration(minutes: 55)),
        );

        when(() => taskRepository.updateTask(any()))
            .thenAnswer((invocation) async {
          final updatedTask = invocation.positionalArguments.first as Task;

          return Right(updatedTask);
        });

        when(() => historyRepository.createHistory(any()))
            .thenAnswer((invocation) async {
          return Right(
            invocation.positionalArguments.first as ActivityHistory,
          );
        });

        final result = await completeTask(task);

        expect(result.isRight(), isTrue);

        final completedTask = result.getOrElse(
          (_) => throw StateError('Expected completion to succeed.'),
        );

        expect(completedTask.status, TaskStatus.completed);
        expect(completedTask.completedAt, isNotNull);
        expect(completedTask.plannedStart, task.plannedStart);
        expect(completedTask.plannedEnd, task.plannedEnd);

        verify(
          () => sessionRepository.getActiveSession(task.id),
        ).called(1);
        verify(
          () => sessionRepository.endSession(any()),
        ).called(1);
        verify(
          () => calculateActualDuration(task.id),
        ).called(1);
        verify(
          () => taskRepository.updateTask(any()),
        ).called(1);
      },
    );

    test(
      'completes paused task without ending another session',
      () async {
        final task = buildTask(
          status: TaskStatus.paused,
          plannedStart: DateTime(2026, 1, 12, 14),
          plannedEnd: DateTime(2026, 1, 12, 15),
        );

        when(() => sessionRepository.getActiveSession(task.id))
            .thenAnswer((_) async => const Right(null));

        when(() => calculateActualDuration(task.id)).thenAnswer(
          (_) async => const Right(Duration(minutes: 30)),
        );

        when(() => taskRepository.updateTask(any()))
            .thenAnswer((invocation) async {
          final updatedTask = invocation.positionalArguments.first as Task;

          return Right(updatedTask);
        });

        when(() => historyRepository.createHistory(any()))
            .thenAnswer((invocation) async {
          return Right(
            invocation.positionalArguments.first as ActivityHistory,
          );
        });

        final result = await completeTask(task);

        expect(result.isRight(), isTrue);

        final completedTask = result.getOrElse(
          (_) => throw StateError('Expected completion to succeed.'),
        );

        expect(completedTask.status, TaskStatus.completed);
        expect(completedTask.completedAt, isNotNull);
        expect(completedTask.plannedStart, task.plannedStart);
        expect(completedTask.plannedEnd, task.plannedEnd);

        verify(
          () => sessionRepository.getActiveSession(task.id),
        ).called(1);
        verifyNever(
          () => sessionRepository.endSession(any()),
        );
        verify(
          () => calculateActualDuration(task.id),
        ).called(1);
        verify(
          () => taskRepository.updateTask(any()),
        ).called(1);
      },
    );

    test('rejects scheduled pending task', () async {
      final task = buildTask(
        status: TaskStatus.pending,
        plannedStart: DateTime(2026, 1, 12, 14),
        plannedEnd: DateTime(2026, 1, 12, 15),
      );

      final result = await completeTask(task);

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => sessionRepository.getActiveSession(any()),
      );
      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('rejects in-progress task without an active session', () async {
      final task = buildTask(
        status: TaskStatus.inProgress,
        plannedStart: DateTime(2026, 1, 12, 14),
        plannedEnd: DateTime(2026, 1, 12, 15),
      );

      when(() => sessionRepository.getActiveSession(task.id))
          .thenAnswer((_) async => const Right(null));

      final result = await completeTask(task);

      expect(result.isLeft(), isTrue);

      verify(
        () => sessionRepository.getActiveSession(task.id),
      ).called(1);
      verifyNever(
        () => sessionRepository.endSession(any()),
      );
      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('rejects completed task', () async {
      final task = buildTask(
        status: TaskStatus.completed,
      );

      final result = await completeTask(task);

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => sessionRepository.getActiveSession(any()),
      );
      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('rejects skipped task', () async {
      final task = buildTask(
        status: TaskStatus.skipped,
      );

      final result = await completeTask(task);

      expect(result.isLeft(), isTrue);

      verifyNever(
        () => sessionRepository.getActiveSession(any()),
      );
      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('propagates active session lookup failure', () async {
      final task = buildTask(
        status: TaskStatus.inProgress,
        plannedStart: DateTime(2026, 1, 12, 14),
        plannedEnd: DateTime(2026, 1, 12, 15),
      );

      const failure = DatabaseFailure(
        'Failed to get active session.',
      );

      when(() => sessionRepository.getActiveSession(task.id))
          .thenAnswer((_) async => const Left(failure));

      final result = await completeTask(task);

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(
        () => sessionRepository.getActiveSession(task.id),
      ).called(1);
      verifyNever(
        () => sessionRepository.endSession(any()),
      );
      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('propagates session end failure', () async {
      final task = buildTask(
        status: TaskStatus.inProgress,
        plannedStart: DateTime(2026, 1, 12, 14),
        plannedEnd: DateTime(2026, 1, 12, 15),
      );

      final activeSession = TaskExecutionSession(
        id: 1,
        taskId: task.id,
        startedAt: DateTime(2026, 1, 12, 14, 5),
      );

      const failure = DatabaseFailure(
        'Failed to end session.',
      );

      when(() => sessionRepository.getActiveSession(task.id))
          .thenAnswer((_) async => Right(activeSession));

      when(() => sessionRepository.endSession(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await completeTask(task);

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(
        () => sessionRepository.getActiveSession(task.id),
      ).called(1);
      verify(
        () => sessionRepository.endSession(any()),
      ).called(1);
      verifyNever(
        () => taskRepository.updateTask(any()),
      );
    });

    test('propagates task update failure', () async {
      final task = buildTask(
        status: TaskStatus.paused,
        plannedStart: DateTime(2026, 1, 12, 14),
        plannedEnd: DateTime(2026, 1, 12, 15),
      );

      const failure = DatabaseFailure(
        'Failed to update task.',
      );

      when(() => sessionRepository.getActiveSession(task.id))
          .thenAnswer((_) async => const Right(null));

      when(() => calculateActualDuration(task.id)).thenAnswer(
        (_) async => const Right(Duration(minutes: 30)),
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await completeTask(task);

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(
        () => sessionRepository.getActiveSession(task.id),
      ).called(1);
      verifyNever(
        () => sessionRepository.endSession(any()),
      );
      verify(
        () => calculateActualDuration(task.id),
      ).called(1);
      verify(
        () => taskRepository.updateTask(any()),
      ).called(1);
    });

    test(
      'creates historical record when a scheduled task is completed',
      () async {
        final task = buildTask(
          status: TaskStatus.inProgress,
          activityId: 10,
          title: 'Flutter development',
          plannedStart: DateTime(2026, 1, 1, 14),
          plannedEnd: DateTime(2026, 1, 1, 15, 30),
        );

        final session = TaskExecutionSession(
          id: 1,
          taskId: task.id,
          startedAt: DateTime(2026, 1, 1, 14),
        );

        when(() => sessionRepository.getActiveSession(task.id)).thenAnswer(
          (_) async => Right(session),
        );

        when(() => sessionRepository.endSession(any())).thenAnswer(
          (invocation) async {
            return Right(
              invocation.positionalArguments.first as TaskExecutionSession,
            );
          },
        );

        when(() => calculateActualDuration(task.id)).thenAnswer(
          (_) async => const Right(Duration(minutes: 90)),
        );

        when(() => taskRepository.updateTask(any())).thenAnswer(
          (invocation) async {
            return Right(
              invocation.positionalArguments.first as Task,
            );
          },
        );

        when(() => historyRepository.createHistory(any())).thenAnswer(
          (invocation) async {
            return Right(
              invocation.positionalArguments.first as ActivityHistory,
            );
          },
        );

        final result = await completeTask(task);

        expect(result.isRight(), isTrue);

        final captured = verify(
          () => historyRepository.createHistory(captureAny()),
        ).captured.single as ActivityHistory;

        expect(captured.taskId, task.id);
        expect(captured.activityId, task.activityId);
        expect(captured.taskTitle, task.title);
        expect(captured.plannedStart, task.plannedStart);
        expect(captured.plannedEnd, task.plannedEnd);
        expect(
          captured.actualDuration,
          const Duration(minutes: 90),
        );
        expect(captured.completedAt, isNotNull);
      },
    );
  });
}