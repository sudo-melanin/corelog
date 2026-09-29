import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/tasks/data/repositories/task_execution_session_repository_impl.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';

void main() {
  late db.AppDatabase database;
  late TaskExecutionSessionRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = TaskExecutionSessionRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  TaskExecutionSession buildSession({
    int id = 0,
    int taskId = 1,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return TaskExecutionSession(
      id: id,
      taskId: taskId,
      startedAt: startedAt ?? DateTime(2026, 1, 1, 14),
      endedAt: endedAt,
    );
  }

  group('createSession', () {
    test('creates an active execution session', () async {
      final result = await repository.createSession(
        buildSession(),
      );

      result.match(
        (failure) => fail(failure.message),
        (session) {
          expect(session.id, greaterThan(0));
          expect(session.taskId, 1);
          expect(
            session.startedAt,
            DateTime(2026, 1, 1, 14),
          );
          expect(session.endedAt, isNull);
        },
      );
    });
  });

  group('getActiveSession', () {
    test('returns the active session for a task', () async {
      await repository.createSession(
        buildSession(),
      );

      final result = await repository.getActiveSession(1);

      result.match(
        (failure) => fail(failure.message),
        (session) {
          expect(session, isNotNull);
          expect(session!.taskId, 1);
          expect(session.endedAt, isNull);
        },
      );
    });

    test('returns null when the task has no active session', () async {
      final result = await repository.getActiveSession(1);

      result.match(
        (failure) => fail(failure.message),
        (session) {
          expect(session, isNull);
        },
      );
    });

    test('ignores ended sessions', () async {
      await repository.createSession(
        buildSession(
          endedAt: DateTime(2026, 1, 1, 14, 45),
        ),
      );

      final result = await repository.getActiveSession(1);

      result.match(
        (failure) => fail(failure.message),
        (session) {
          expect(session, isNull);
        },
      );
    });
  });

  group('getSessionsByTask', () {
    test('returns all sessions for a task', () async {
      await repository.createSession(
        buildSession(
          startedAt: DateTime(2026, 1, 1, 14),
          endedAt: DateTime(2026, 1, 1, 14, 45),
        ),
      );

      await repository.createSession(
        buildSession(
          startedAt: DateTime(2026, 1, 1, 15),
          endedAt: DateTime(2026, 1, 1, 15, 50),
        ),
      );

      final result = await repository.getSessionsByTask(1);

      result.match(
        (failure) => fail(failure.message),
        (sessions) {
          expect(sessions, hasLength(2));
          expect(sessions[0].taskId, 1);
          expect(sessions[1].taskId, 1);
        },
      );
    });

    test('does not return sessions belonging to another task', () async {
      await repository.createSession(
        buildSession(taskId: 1),
      );

      await repository.createSession(
        buildSession(taskId: 2),
      );

      final result = await repository.getSessionsByTask(1);

      result.match(
        (failure) => fail(failure.message),
        (sessions) {
          expect(sessions, hasLength(1));
          expect(sessions.single.taskId, 1);
        },
      );
    });
  });

  group('endSession', () {
    test('sets endedAt and preserves the session history', () async {
      final createdResult = await repository.createSession(
        buildSession(),
      );

      final createdSession = createdResult.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      final endedAt = DateTime(2026, 1, 1, 14, 45);

      final result = await repository.endSession(
        TaskExecutionSession(
          id: createdSession.id,
          taskId: createdSession.taskId,
          startedAt: createdSession.startedAt,
          endedAt: endedAt,
        ),
      );

      result.match(
        (failure) => fail(failure.message),
        (session) {
          expect(session.id, createdSession.id);
          expect(session.startedAt, createdSession.startedAt);
          expect(session.endedAt, endedAt);
        },
      );

      final historyResult = await repository.getSessionsByTask(1);

      historyResult.match(
        (failure) => fail(failure.message),
        (sessions) {
          expect(sessions, hasLength(1));
          expect(sessions.single.endedAt, endedAt);
        },
      );
    });

    test('returns failure when session does not exist', () async {
      final result = await repository.endSession(
        buildSession(
          id: 999,
          endedAt: DateTime(2026, 1, 1, 14, 45),
        ),
      );

      expect(result.isLeft(), isTrue);
    });
  });
}