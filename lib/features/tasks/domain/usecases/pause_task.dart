import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class PauseTask {
  const PauseTask({
    required this._taskRepository,
    required this._sessionRepository,
  });

  final TaskRepository _taskRepository;
  final TaskExecutionSessionRepository _sessionRepository;

  Future<Either<Failure, Task>> call(Task task) async {
    if (task.status != TaskStatus.inProgress) {
      return const Left(
        ValidationFailure('Only in-progress tasks can be paused.'),
      );
    }

    final activeSessionResult =
        await _sessionRepository.getActiveSession(task.id);

    return activeSessionResult.match(
      Left.new,
      (activeSession) async {
        if (activeSession == null) {
          return const Left(
            ValidationFailure(
              'Task does not have an active execution session.',
            ),
          );
        }

        final now = DateTime.now();

        final endedSessionResult =
            await _sessionRepository.endSession(
          activeSession.copyWith(endedAt: now),
        );

        return endedSessionResult.match(
          Left.new,
          (_) {
            final updatedTask = Task(
              id: task.id,
              activityId: task.activityId,
              title: task.title,
              description: task.description,
              status: TaskStatus.paused,
              dueDate: task.dueDate,
              plannedStart: task.plannedStart,
              plannedEnd: task.plannedEnd,
              completedAt: task.completedAt,
              createdAt: task.createdAt,
              updatedAt: now,
            );

            return _taskRepository.updateTask(updatedTask);
          },
        );
      },
    );
  }
}