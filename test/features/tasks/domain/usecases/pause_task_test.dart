import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/pause_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockSessionRepository extends Mock
    implements TaskExecutionSessionRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late MockSessionRepository sessionRepository;
  late PauseTask pauseTask;

  setUpAll(() {
    registerFallbackValue(
      Task(
        id: 0,
        title: '',
        status: TaskStatus.pending,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

    registerFallbackValue(
      TaskExecutionSession(
        id: 0,
        taskId: 0,
        startedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    taskRepository = MockTaskRepository();
    sessionRepository = MockSessionRepository();

    pauseTask = PauseTask(
      taskRepository: taskRepository,
      sessionRepository: sessionRepository,
    );
  });

  Task buildTask({
    TaskStatus status = TaskStatus.inProgress,
  }) {
    return Task(
      id: 1,
      activityId: 2,
      title: 'Study Flutter',
      description: 'Work on CoreLog',
      status: status,
      dueDate: DateTime(2026, 1, 1, 18),
      plannedStart: DateTime(2026, 1, 1, 14),
      plannedEnd: DateTime(2026, 1, 1, 15),
      createdAt: DateTime(2026, 1, 1, 9),
      updatedAt: DateTime(2026, 1, 1, 10),
    );
  }

  TaskExecutionSession buildActiveSession() {
    return TaskExecutionSession(
      id: 10,
      taskId: 1,
      startedAt: DateTime(2026, 1, 1, 14),
    );
  }

  group('PauseTask', () {
    test('ends active session and pauses the task', () async {
      final activeSession = buildActiveSession();

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => Right(activeSession),
      );

      when(() => sessionRepository.endSession(any())).thenAnswer(
        (invocation) async {
          final session =
              invocation.positionalArguments.first as TaskExecutionSession;

          return Right(session);
        },
      );

      when(() => taskRepository.updateTask(any())).thenAnswer(
        (invocation) async {
          final task = invocation.positionalArguments.first as Task;
          return Right(task);
        },
      );

      final result = await pauseTask(buildTask());

      expect(result.isRight(), isTrue);

      final updatedTask = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTask.status, TaskStatus.paused);
      expect(updatedTask.plannedStart, DateTime(2026, 1, 1, 14));
      expect(updatedTask.plannedEnd, DateTime(2026, 1, 1, 15));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.endSession(any())).called(1);
      verify(() => taskRepository.updateTask(any())).called(1);
    });

    test('rejects a task that is not in progress', () async {
      final result = await pauseTask(
        buildTask(status: TaskStatus.pending),
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Only in-progress tasks can be paused.',
          );
        },
        (_) => fail('Expected validation failure.'),
      );

      verifyNever(() => sessionRepository.getActiveSession(any()));
      verifyNever(() => sessionRepository.endSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('rejects an in-progress task without an active session', () async {
      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Right(null),
      );

      final result = await pauseTask(buildTask());

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Task does not have an active execution session.',
          );
        },
        (_) => fail('Expected validation failure.'),
      );

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verifyNever(() => sessionRepository.endSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates active-session lookup failure', () async {
      const failure = DatabaseFailure(
        'Unable to read execution session.',
      );

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await pauseTask(buildTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verifyNever(() => sessionRepository.endSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates session ending failure', () async {
      const failure = DatabaseFailure(
        'Unable to end execution session.',
      );

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => Right(buildActiveSession()),
      );

      when(() => sessionRepository.endSession(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await pauseTask(buildTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.endSession(any())).called(1);
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates task update failure', () async {
      const failure = DatabaseFailure(
        'Unable to pause task.',
      );

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => Right(buildActiveSession()),
      );

      when(() => sessionRepository.endSession(any())).thenAnswer(
        (invocation) async {
          final session =
              invocation.positionalArguments.first as TaskExecutionSession;

          return Right(session);
        },
      );

      when(() => taskRepository.updateTask(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await pauseTask(buildTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.endSession(any())).called(1);
      verify(() => taskRepository.updateTask(any())).called(1);
    });
  });
}