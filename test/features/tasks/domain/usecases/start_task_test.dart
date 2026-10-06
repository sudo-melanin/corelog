import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/start_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockSessionRepository extends Mock
    implements TaskExecutionSessionRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late MockSessionRepository sessionRepository;
  late StartTask startTask;

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

    startTask = StartTask(
      taskRepository: taskRepository,
      sessionRepository: sessionRepository,
    );
  });

  Task buildScheduledTask({
    TaskStatus status = TaskStatus.pending,
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

  group('StartTask', () {
    test('starts a scheduled pending task and creates an active session',
        () async {
      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Right(null),
      );

      when(() => sessionRepository.createSession(any())).thenAnswer(
        (invocation) async {
          final session =
              invocation.positionalArguments.first as TaskExecutionSession;

          return Right(
            TaskExecutionSession(
              id: 10,
              taskId: session.taskId,
              startedAt: session.startedAt,
            ),
          );
        },
      );

      when(() => taskRepository.updateTask(any())).thenAnswer(
        (invocation) async {
          final task = invocation.positionalArguments.first as Task;
          return Right(task);
        },
      );

      final result = await startTask(buildScheduledTask());

      expect(result.isRight(), isTrue);

      final updatedTask = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTask.status, TaskStatus.inProgress);
      expect(updatedTask.plannedStart, DateTime(2026, 1, 1, 14));
      expect(updatedTask.plannedEnd, DateTime(2026, 1, 1, 15));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.createSession(any())).called(1);
      verify(() => taskRepository.updateTask(any())).called(1);
    });

    test('rejects an unscheduled task', () async {
      final task = Task(
        id: 1,
        title: 'Unscheduled task',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 1, 9),
        updatedAt: DateTime(2026, 1, 1, 10),
      );

      final result = await startTask(task);

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Only scheduled tasks can be started.',
          );
        },
        (_) => fail('Expected validation failure.'),
      );

      verifyNever(() => sessionRepository.getActiveSession(any()));
      verifyNever(() => sessionRepository.createSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('rejects a task that is not pending', () async {
      final result = await startTask(
        buildScheduledTask(status: TaskStatus.paused),
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Only pending tasks can be started.',
          );
        },
        (_) => fail('Expected validation failure.'),
      );

      verifyNever(() => sessionRepository.getActiveSession(any()));
      verifyNever(() => sessionRepository.createSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('rejects a task with an active session', () async {
      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => Right(
          TaskExecutionSession(
            id: 10,
            taskId: 1,
            startedAt: DateTime(2026, 1, 1, 14),
          ),
        ),
      );

      final result = await startTask(buildScheduledTask());

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Task already has an active session.',
          );
        },
        (_) => fail('Expected validation failure.'),
      );

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verifyNever(() => sessionRepository.createSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates active-session lookup failure', () async {
      const failure = DatabaseFailure('Unable to read execution session.');

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await startTask(buildScheduledTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verifyNever(() => sessionRepository.createSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates session creation failure', () async {
      const failure = DatabaseFailure('Unable to create execution session.');

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Right(null),
      );

      when(() => sessionRepository.createSession(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await startTask(buildScheduledTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.createSession(any())).called(1);
      verifyNever(() => taskRepository.updateTask(any()));
    });
  });
}