import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';

class TaskTiming {
  const TaskTiming._();

  static bool isOverdue(
    Task task, {
    required DateTime now,
  }) {
    final plannedEnd = task.plannedEnd;

    if (plannedEnd == null) {
      return false;
    }

    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.skipped) {
      return false;
    }

    return now.isAfter(plannedEnd);
  }

  static DateTime? actualStart(
    List<TaskExecutionSession> sessions,
  ) {
    if (sessions.isEmpty) {
      return null;
    }

    return sessions
        .map((session) => session.startedAt)
        .reduce(
          (earliest, current) =>
              current.isBefore(earliest) ? current : earliest,
        );
  }

  static DateTime? latestPause(
    List<TaskExecutionSession> sessions,
  ) {
    final endedSessions = sessions
        .where((session) => session.endedAt != null)
        .toList();

    if (endedSessions.isEmpty) {
      return null;
    }

    endedSessions.sort(
      (a, b) => a.endedAt!.compareTo(b.endedAt!),
    );

    return endedSessions.last.endedAt;
  }

  static Duration? remaining(
    Task task, {
    required DateTime now,
    DateTime? pausedAt,
  }) {
    final plannedEnd = task.plannedEnd;

    if (plannedEnd == null) {
      return null;
    }

    final referenceTime = task.status == TaskStatus.paused && pausedAt != null
        ? pausedAt
        : now;

    final difference = plannedEnd.difference(referenceTime);

    return difference.isNegative ? Duration.zero : difference;
  }

  static Duration? overdueDuration(
    Task task, {
    required DateTime now,
    DateTime? pausedAt,
  }) {
    final plannedEnd = task.plannedEnd;

    if (plannedEnd == null ||
        !isOverdue(
          task,
          now: now,
        )) {
      return null;
    }

    final referenceTime = task.status == TaskStatus.paused && pausedAt != null
        ? pausedAt
        : now;

    final difference = referenceTime.difference(plannedEnd);

    return difference.isNegative ? Duration.zero : difference;
  }
}