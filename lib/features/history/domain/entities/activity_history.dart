import 'package:equatable/equatable.dart';

class ActivityHistory extends Equatable {
  const ActivityHistory({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.completedAt,
    required this.actualDuration,
    this.activityId,
    this.plannedStart,
    this.plannedEnd,
  });

  final int id;

  /// Original task reference. It is intentionally not a foreign key.
  final int taskId;

  /// Original activity reference. It is intentionally not a foreign key.
  final int? activityId;

  /// Snapshot of the task title at completion time.
  final String taskTitle;

  /// Snapshot of the planned start time.
  final DateTime? plannedStart;

  /// Snapshot of the planned end time.
  final DateTime? plannedEnd;

  final DateTime completedAt;

  /// Total active execution time recorded by execution sessions.
  final Duration actualDuration;

  @override
  List<Object?> get props => [
        id,
        taskId,
        activityId,
        taskTitle,
        plannedStart,
        plannedEnd,
        completedAt,
        actualDuration,
      ];
}