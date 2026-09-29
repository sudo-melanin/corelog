import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/resume_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockSessionRepository extends Mock
    implements TaskExecutionSessionRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late MockSessionRepository sessionRepository;
  late ResumeTask resumeTask;

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

    resumeTask = ResumeTask(
      taskRepository: taskRepository,
      sessionRepository: sessionRepository,
    );
  });

  Task buildPausedTask({
    TaskStatus status = TaskStatus.paused,
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

  group('ResumeTask', () {
    test('creates a new active session and resumes the task', () async {
      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Right(null),
      );

      when(() => sessionRepository.createSession(any())).thenAnswer(
        (invocation) async {
          final session =
              invocation.positionalArguments.first as TaskExecutionSession;

          return Right(
            TaskExecutionSession(
              id: 20,
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

      final result = await resumeTask(buildPausedTask());

      expect(result.isRight(), isTrue);

      final updatedTask = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTask.status, TaskStatus.inProgress);
      expect(updatedTask.plannedStart, DateTime(2026, 1, 1, 14));
      expect(updatedTask.plannedEnd, DateTime(2026, 1, 1, 15));

      final captured = verify(
        () => sessionRepository.createSession(captureAny()),
      ).captured.single as TaskExecutionSession;

      expect(captured.id, 0);
      expect(captured.taskId, 1);
      expect(captured.startedAt, isNotNull);
      expect(captured.endedAt, isNull);

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => taskRepository.updateTask(any())).called(1);
    });

    test('rejects a task that is not paused', () async {
      final result = await resumeTask(
        buildPausedTask(status: TaskStatus.inProgress),
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Only paused tasks can be resumed.',
          );
        },
        (_) => fail('Expected validation failure.'),
      );

      verifyNever(() => sessionRepository.getActiveSession(any()));
      verifyNever(() => sessionRepository.createSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('rejects a task that already has an active session', () async {
      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => Right(
          TaskExecutionSession(
            id: 10,
            taskId: 1,
            startedAt: DateTime(2026, 1, 1, 15),
          ),
        ),
      );

      final result = await resumeTask(buildPausedTask());

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
      const failure = DatabaseFailure(
        'Unable to read execution session.',
      );

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await resumeTask(buildPausedTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verifyNever(() => sessionRepository.createSession(any()));
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates session creation failure', () async {
      const failure = DatabaseFailure(
        'Unable to create execution session.',
      );

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Right(null),
      );

      when(() => sessionRepository.createSession(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await resumeTask(buildPausedTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.createSession(any())).called(1);
      verifyNever(() => taskRepository.updateTask(any()));
    });

    test('propagates task update failure', () async {
      const failure = DatabaseFailure(
        'Unable to resume task.',
      );

      when(() => sessionRepository.getActiveSession(1)).thenAnswer(
        (_) async => const Right(null),
      );

      when(() => sessionRepository.createSession(any())).thenAnswer(
        (invocation) async {
          final session =
              invocation.positionalArguments.first as TaskExecutionSession;

          return Right(
            TaskExecutionSession(
              id: 20,
              taskId: session.taskId,
              startedAt: session.startedAt,
            ),
          );
        },
      );

      when(() => taskRepository.updateTask(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await resumeTask(buildPausedTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => sessionRepository.getActiveSession(1)).called(1);
      verify(() => sessionRepository.createSession(any())).called(1);
      verify(() => taskRepository.updateTask(any())).called(1);
    });
  });
}