import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class GetTodayTasks {
const GetTodayTasks(this._repository);

final TaskRepository _repository;

Future<Either<Failure, List<Task>>> call(DateTime now) async {
final result = await _repository.getTasks();

return result.map(
  (tasks) {
    final startOfToday = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfTomorrow = startOfToday.add(
      const Duration(days: 1),
    );

    return tasks.where((task) {
      if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.skipped) {
      return false;
    }
      final isActive =
          task.status == TaskStatus.inProgress ||
          task.status == TaskStatus.paused;

      if (isActive) {
        return true;
      }

      final isUnscheduledPending =
          task.status == TaskStatus.pending &&
          task.plannedStart == null &&
          task.plannedEnd == null;

      if (isUnscheduledPending) {
        return true;
      }

      final plannedStart = task.plannedStart;
      final plannedEnd = task.plannedEnd;

      if (plannedStart == null || plannedEnd == null) {
        return false;
      }

      final overlapsToday =
          plannedStart.isBefore(startOfTomorrow) &&
          plannedEnd.isAfter(startOfToday);

      return overlapsToday;
    }).toList();
  },
);
}
}
