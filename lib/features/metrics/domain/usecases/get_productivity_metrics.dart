import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';
import 'package:corelog/features/metrics/domain/entities/productivity_metrics.dart';

class GetProductivityMetrics {
  const GetProductivityMetrics(this._historyRepository);

  final ActivityHistoryRepository _historyRepository;

  Future<Either<Failure, ProductivityMetrics>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final historyResult = await _historyRepository.getHistory();

    return historyResult.map(
      (history) => _calculate(
        history: history,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  ProductivityMetrics _calculate({
    required List<ActivityHistory> history,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final periodHistory = history.where((item) {
      return !item.occurredAt.isBefore(startDate) &&
          item.occurredAt.isBefore(endDate);
    });

    var completedTaskCount = 0;
    var skippedTaskCount = 0;
    var plannedDuration = Duration.zero;
    var actualDuration = Duration.zero;

    final activityBreakdown = <int, Duration>{};
    final skipReasonBreakdown = <TaskSkipReason, int>{};

    for (final item in periodHistory) {
      if (item.outcome == HistoryOutcome.completed) {
        completedTaskCount++;
        actualDuration += item.actualDuration;

        if (item.plannedStart != null &&
            item.plannedEnd != null) {
          plannedDuration +=
              item.plannedEnd!.difference(item.plannedStart!);
        }

        if (item.activityId != null) {
          activityBreakdown[item.activityId!] =
              (activityBreakdown[item.activityId!] ??
                      Duration.zero) +
                  item.actualDuration;
        }
      } else {
        skippedTaskCount++;

        if (item.skipReason != null) {
          skipReasonBreakdown[item.skipReason!] =
              (skipReasonBreakdown[item.skipReason!] ?? 0) + 1;
        }
      }
    }

    return ProductivityMetrics(
      startDate: startDate,
      endDate: endDate,
      completedTaskCount: completedTaskCount,
      skippedTaskCount: skippedTaskCount,
      plannedDuration: plannedDuration,
      actualDuration: actualDuration,
      activityBreakdown: activityBreakdown,
      skipReasonBreakdown: skipReasonBreakdown,
    );
  }
}