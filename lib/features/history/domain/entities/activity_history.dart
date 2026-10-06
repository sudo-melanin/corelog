import 'package:equatable/equatable.dart';

import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';

class ActivityHistory extends Equatable {
  const ActivityHistory({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.outcome,
    required this.occurredAt,
    required this.actualDuration,
    this.activityId,
    this.plannedStart,
    this.plannedEnd,
    this.skipReason,
    this.skipNote,
  });

  final int id;
  final int taskId;
  final int? activityId;
  final String taskTitle;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final HistoryOutcome outcome;
  final DateTime occurredAt;
  final Duration actualDuration;
  final TaskSkipReason? skipReason;
  final String? skipNote;

  @override
  List<Object?> get props => [
        id,
        taskId,
        activityId,
        taskTitle,
        plannedStart,
        plannedEnd,
        outcome,
        occurredAt,
        actualDuration,
        skipReason,
        skipNote,
      ];
}