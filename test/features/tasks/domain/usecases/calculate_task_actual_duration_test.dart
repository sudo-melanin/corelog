import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/calculate_task_actual_duration.dart';

class MockTaskExecutionSessionRepository extends Mock
    implements TaskExecutionSessionRepository {}

void main() {
  late MockTaskExecutionSessionRepository repository;
  late CalculateTaskActualDuration calculateDuration;

  setUp(() {
    repository = MockTaskExecutionSessionRepository();
    calculateDuration = CalculateTaskActualDuration(repository);
  });

  TaskExecutionSession session({
    required int id,
    required DateTime startedAt,
    DateTime? endedAt,
  }) {
    return TaskExecutionSession(
      id: id,
      taskId: 1,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  group('CalculateTaskActualDuration', () {
    test('returns zero when task has no sessions', () async {
      when(() => repository.getSessionsByTask(1)).thenAnswer(
        (_) async => const Right([]),
      );

      final result = await calculateDuration(1);

      expect(result, const Right(Duration.zero));
    });

    test('calculates duration for one completed session', () async {
      final startedAt = DateTime(2026, 1, 1, 14);
      final endedAt = DateTime(2026, 1, 1, 15, 30);

      when(() => repository.getSessionsByTask(1)).thenAnswer(
        (_) async => Right([
          session(
            id: 1,
            startedAt: startedAt,
            endedAt: endedAt,
          ),
        ]),
      );

      final result = await calculateDuration(1);

      expect(result, const Right(Duration(minutes: 90)));
    });

    test('sums multiple completed sessions', () async {
      when(() => repository.getSessionsByTask(1)).thenAnswer(
        (_) async => Right([
          session(
            id: 1,
            startedAt: DateTime(2026, 1, 1, 14),
            endedAt: DateTime(2026, 1, 1, 14, 40),
          ),
          session(
            id: 2,
            startedAt: DateTime(2026, 1, 1, 15),
            endedAt: DateTime(2026, 1, 1, 15, 50),
          ),
        ]),
      );

      final result = await calculateDuration(1);

      expect(result, const Right(Duration(minutes: 90)));
    });

    test('ignores an active session without an end time', () async {
      when(() => repository.getSessionsByTask(1)).thenAnswer(
        (_) async => Right([
          session(
            id: 1,
            startedAt: DateTime(2026, 1, 1, 14),
            endedAt: DateTime(2026, 1, 1, 14, 40),
          ),
          session(
            id: 2,
            startedAt: DateTime(2026, 1, 1, 15),
          ),
        ]),
      );

      final result = await calculateDuration(1);

      expect(result, const Right(Duration(minutes: 40)));
    });

    test('propagates repository failure', () async {
      const failure = DatabaseFailure('Could not load sessions.');

      when(() => repository.getSessionsByTask(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await calculateDuration(1);

      expect(result, const Left(failure));
    });
  });
}