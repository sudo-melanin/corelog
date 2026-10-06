import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_timing.dart';

class TodayTaskGroups {
  const TodayTaskGroups({
    required this.now,
    required this.overdue,
    required this.upNext,
    required this.unscheduled,
  });

  final List<Task> now;
  final List<Task> overdue;
  final List<Task> upNext;
  final List<Task> unscheduled;

  factory TodayTaskGroups.fromTasks(
    List<Task> tasks, {
    required DateTime currentTime,
  }) {
    final sortedTasks = [...tasks];

    sortedTasks.sort((a, b) {
      final aStart = a.plannedStart;
      final bStart = b.plannedStart;

      if (aStart == null && bStart == null) {
        return 0;
      }

      if (aStart == null) {
        return 1;
      }

      if (bStart == null) {
        return -1;
      }

      return aStart.compareTo(bStart);
    });

    return TodayTaskGroups(
      now: _nowTasks(sortedTasks, currentTime),
      overdue: _overdueTasks(sortedTasks, currentTime),
      upNext: _upNextTasks(sortedTasks, currentTime),
      unscheduled: _unscheduledTasks(sortedTasks),
    );
  }

  static List<Task> _nowTasks(
    List<Task> tasks,
    DateTime currentTime,
  ) {
    return tasks.where((task) {
      if (TaskTiming.isOverdue(task, now: currentTime)) {
        return false;
      }

      if (task.status == TaskStatus.inProgress ||
          task.status == TaskStatus.paused) {
        return true;
      }

      final plannedStart = task.plannedStart;
      final plannedEnd = task.plannedEnd;

      return task.status == TaskStatus.pending &&
          plannedStart != null &&
          plannedEnd != null &&
          !currentTime.isBefore(plannedStart) &&
          currentTime.isBefore(plannedEnd);
    }).toList();
  }

  static List<Task> _overdueTasks(
    List<Task> tasks,
    DateTime currentTime,
  ) {
    return tasks
        .where(
          (task) => TaskTiming.isOverdue(
            task,
            now: currentTime,
          ),
        )
        .toList();
  }

  static List<Task> _upNextTasks(
    List<Task> tasks,
    DateTime currentTime,
  ) {
    return tasks.where((task) {
      final plannedStart = task.plannedStart;

      return task.status == TaskStatus.pending &&
          plannedStart != null &&
          plannedStart.isAfter(currentTime) &&
          !TaskTiming.isOverdue(
            task,
            now: currentTime,
          );
    }).toList();
  }

  static List<Task> _unscheduledTasks(List<Task> tasks) {
    return tasks
        .where(
          (task) =>
              task.status == TaskStatus.pending &&
              task.plannedStart == null &&
              task.plannedEnd == null,
        )
        .toList();
  }
}