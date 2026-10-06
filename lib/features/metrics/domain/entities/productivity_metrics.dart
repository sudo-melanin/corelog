import 'package:equatable/equatable.dart';

import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';

class ProductivityMetrics extends Equatable {
  const ProductivityMetrics({
    required this.startDate,
    required this.endDate,
    required this.completedTaskCount,
    required this.skippedTaskCount,
    required this.plannedDuration,
    required this.actualDuration,
    required this.activityBreakdown,
    required this.skipReasonBreakdown,
  });

  final DateTime startDate;
  final DateTime endDate;

  final int completedTaskCount;
  final int skippedTaskCount;

  final Duration plannedDuration;
  final Duration actualDuration;

  final Map<int, Duration> activityBreakdown;

  final Map<TaskSkipReason, int> skipReasonBreakdown;

  int get totalTerminalTaskCount =>
      completedTaskCount + skippedTaskCount;

  double get completionRate {
    if (totalTerminalTaskCount == 0) {
      return 0;
    }

    return completedTaskCount / totalTerminalTaskCount;
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        completedTaskCount,
        skippedTaskCount,
        plannedDuration,
        actualDuration,
        activityBreakdown,
        skipReasonBreakdown,
      ];
}