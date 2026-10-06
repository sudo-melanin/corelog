import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class CompleteTask {
  const CompleteTask({
    required this._taskRepository,
    required this._sessionRepository,
    required this._historyRepository,
    required this._calculateActualDuration,
  });

  final TaskRepository _taskRepository;
  final TaskExecutionSessionRepository _sessionRepository;
  final ActivityHistoryRepository _historyRepository;
  final Future<Either<Failure, Duration>> Function(int taskId)
      _calculateActualDuration;

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

    final now = DateTime.now();

    if (isUnscheduledPendingTask) {
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

      final taskResult = await _taskRepository.updateTask(completedTask);

      return taskResult.match(
        Left.new,
        (updatedTask) async {
          final historyResult = await _createHistory(
            task: updatedTask,
            actualDuration: Duration.zero,
          );

          return historyResult.match(
            Left.new,
            (_) => Right(updatedTask),
          );
        },
      );
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

        if (activeSession != null) {
          final endedSessionResult = await _sessionRepository.endSession(
            activeSession.copyWith(endedAt: now),
          );

          final sessionFailure = endedSessionResult.fold(
            (failure) => failure,
            (_) => null
          );

          if (sessionFailure != null) {
            return Left(sessionFailure);
          }
        }

        final durationResult = await _calculateActualDuration(task.id);

        return durationResult.match(
          Left.new,
          (actualDuration) async {
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

            final taskResult =
                await _taskRepository.updateTask(completedTask);

            return taskResult.match(
              Left.new,
              (updatedTask) async {
                final historyResult = await _createHistory(
                  task: updatedTask,
                  actualDuration: actualDuration,
                );

                return historyResult.match(
                  Left.new,
                  (_) => Right(updatedTask),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, ActivityHistory>> _createHistory({
  required Task task,
  required Duration actualDuration,
}) {
  return _historyRepository.createHistory(
    ActivityHistory(
      id: 0,
      taskId: task.id,
      activityId: task.activityId,
      taskTitle: task.title,
      plannedStart: task.plannedStart,
      plannedEnd: task.plannedEnd,
      outcome: HistoryOutcome.completed,
      occurredAt: task.completedAt!,
      actualDuration: actualDuration,
    ),
  );
}
}