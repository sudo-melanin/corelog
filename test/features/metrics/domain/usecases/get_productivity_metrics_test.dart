import 'package:corelog/core/error/failures.dart';
import 'package:corelog/features/metrics/domain/entities/productivity_metrics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';
import 'package:corelog/features/metrics/domain/usecases/get_productivity_metrics.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';

class MockActivityHistoryRepository extends Mock
    implements ActivityHistoryRepository {}

void main() {
  late MockActivityHistoryRepository historyRepository;
  late GetProductivityMetrics getProductivityMetrics;

  final startDate = DateTime(2026, 10, 1);
  final endDate = DateTime(2026, 10, 2);

  setUp(() {
    historyRepository = MockActivityHistoryRepository();

    getProductivityMetrics = GetProductivityMetrics(
      historyRepository,
    );
  });

  ActivityHistory completedHistory({
    int id = 1,
    int taskId = 1,
    int? activityId = 10,
    DateTime? occurredAt,
    Duration actualDuration = const Duration(minutes: 45),
    DateTime? plannedStart,
    DateTime? plannedEnd,
  }) {
    return ActivityHistory(
      id: id,
      taskId: taskId,
      activityId: activityId,
      taskTitle: 'Completed task',
      outcome: HistoryOutcome.completed,
      occurredAt: occurredAt ?? DateTime(2026, 10, 1, 10),
      actualDuration: actualDuration,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
    );
  }

  ActivityHistory skippedHistory({
    int id = 2,
    int taskId = 2,
    int? activityId = 10,
    DateTime? occurredAt,
    TaskSkipReason reason = TaskSkipReason.notEnoughTime,
  }) {
    return ActivityHistory(
      id: id,
      taskId: taskId,
      activityId: activityId,
      taskTitle: 'Skipped task',
      outcome: HistoryOutcome.skipped,
      occurredAt: occurredAt ?? DateTime(2026, 10, 1, 12),
      actualDuration: Duration.zero,
      skipReason: reason,
    );
  }

  test(
    'calculates completed and skipped task counts',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => Right([
          completedHistory(),
          skippedHistory(),
        ]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(metrics.completedTaskCount, 1);
      expect(metrics.skippedTaskCount, 1);
      expect(metrics.totalTerminalTaskCount, 2);
      expect(metrics.completionRate, 0.5);
    },
  );

  test(
    'calculates planned and actual duration for completed scheduled tasks',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => Right([
          completedHistory(
            plannedStart: DateTime(2026, 10, 1, 10),
            plannedEnd: DateTime(2026, 10, 1, 11),
            actualDuration: const Duration(minutes: 45),
          ),
        ]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(
        metrics.plannedDuration,
        const Duration(hours: 1),
      );
      expect(
        metrics.actualDuration,
        const Duration(minutes: 45),
      );
    },
  );

  test(
    'does not add planned duration for unscheduled completed tasks',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => Right([
          completedHistory(
            actualDuration: const Duration(minutes: 20),
          ),
        ]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(metrics.plannedDuration, Duration.zero);
      expect(
        metrics.actualDuration,
        const Duration(minutes: 20),
      );
    },
  );

  test(
    'tracks actual duration by activity',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => Right([
          completedHistory(
            id: 1,
            activityId: 10,
            actualDuration: const Duration(minutes: 30),
          ),
          completedHistory(
            id: 2,
            activityId: 10,
            actualDuration: const Duration(minutes: 20),
          ),
          completedHistory(
            id: 3,
            activityId: 20,
            actualDuration: const Duration(minutes: 15),
          ),
        ]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(
        metrics.activityBreakdown[10],
        const Duration(minutes: 50),
      );
      expect(
        metrics.activityBreakdown[20],
        const Duration(minutes: 15),
      );
    },
  );

  test(
    'tracks skipped tasks by reason',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => Right([
          skippedHistory(
            id: 1,
            reason: TaskSkipReason.notEnoughTime,
          ),
          skippedHistory(
            id: 2,
            reason: TaskSkipReason.notEnoughTime,
          ),
          skippedHistory(
            id: 3,
            reason: TaskSkipReason.higherPriorityCameUp,
          ),
        ]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(
        metrics.skipReasonBreakdown[TaskSkipReason.notEnoughTime],
        2,
      );
      expect(
        metrics.skipReasonBreakdown[
          TaskSkipReason.higherPriorityCameUp
        ],
        1,
      );
    },
  );

  test(
    'ignores history outside the requested period',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => Right([
          completedHistory(
            occurredAt: DateTime(2026, 9, 30, 23, 59),
          ),
          completedHistory(
            id: 2,
            occurredAt: DateTime(2026, 10, 1, 10),
          ),
          completedHistory(
            id: 3,
            occurredAt: DateTime(2026, 10, 2),
          ),
        ]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(metrics.completedTaskCount, 1);
    },
  );

  test(
    'returns zero completion rate when there are no outcomes',
    () async {
      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => const Right([]),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      final metrics = result.getOrElse(
        (_) => throw StateError('Expected metrics to succeed.'),
      );

      expect(metrics.totalTerminalTaskCount, 0);
      expect(metrics.completionRate, 0);
    },
  );

  test(
    'propagates history repository failure',
    () async {
      const failure = DatabaseFailure(
        'Failed to load history.',
      );

      when(() => historyRepository.getHistory()).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await getProductivityMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      expect(
        result,
        const Left<Failure, ProductivityMetrics>(failure),
      );
    },
  );
}