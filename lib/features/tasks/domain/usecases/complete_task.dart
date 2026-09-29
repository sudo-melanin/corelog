import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class CompleteTask {
  const CompleteTask({
    required this._taskRepository,
    required this._sessionRepository,
  });

  final TaskRepository _taskRepository;
  final TaskExecutionSessionRepository _sessionRepository;

  Future<Either<Failure, Task>> call(Task task) async {
    final isUnscheduledPendingTask =
      task.status == TaskStatus.pending &&
      task.plannedStart == null &&
      task.plannedEnd == null;

    final isActiveTask =
      task.status == TaskStatus.inProgress ||
      task.status == TaskStatus.paused;

    if (!isUnscheduledPendingTask && !isActiveTask) {
      return const Left(
        ValidationFailure(
          'Only unscheduled pending, in-progress, or paused tasks can be completed.',
        ),
      );
    }
    if (isUnscheduledPendingTask) {
      final now = DateTime.now();

      final completedTask = Task(
        id: task.id,
        activityId: task.activityId,
        title: task.title,
        description: task.description,
        status: TaskStatus.completed,
        dueDate: task.dueDate,
        plannedStart: task.plannedStart,
        plannedEnd: task.plannedEnd,
        completedAt: now,
        createdAt: task.createdAt,
        updatedAt: now,
      );

      return _taskRepository.updateTask(completedTask);
    }


    final activeSessionResult =
        await _sessionRepository.getActiveSession(task.id);

    return activeSessionResult.match(
      Left.new,
      (activeSession) async {
        if (task.status == TaskStatus.inProgress &&
            activeSession == null) {
          return const Left(
            ValidationFailure(
              'In-progress task does not have an active execution session.',
            ),
          );
        }

        final now = DateTime.now();

        if (activeSession != null) {
          final endedSessionResult = await _sessionRepository.endSession(
            activeSession.copyWith(endedAt: now),
          );

          final sessionFailure = endedSessionResult.swap().toOption();

          if (sessionFailure.isSome()) {
            return Left(sessionFailure.toNullable()!);
          }
        }

        final completedTask = Task(
          id: task.id,
          activityId: task.activityId,
          title: task.title,
          description: task.description,
          status: TaskStatus.completed,
          dueDate: task.dueDate,
          plannedStart: task.plannedStart,
          plannedEnd: task.plannedEnd,
          completedAt: now,
          createdAt: task.createdAt,
          updatedAt: now,
        );

        return _taskRepository.updateTask(completedTask);
      },
    );
  }
}