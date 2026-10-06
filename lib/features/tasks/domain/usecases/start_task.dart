import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class StartTask {
  const StartTask({
    required this._taskRepository,
    required this._sessionRepository,
  });

  final TaskRepository _taskRepository;
  final TaskExecutionSessionRepository _sessionRepository;

  Future<Either<Failure, Task>> call(Task task) async {
    if (task.status != TaskStatus.pending) {
      return const Left(
        ValidationFailure('Only pending tasks can be started.'),
      );
    }

    if (task.plannedStart == null || task.plannedEnd == null) {
      return const Left(
        ValidationFailure('Only scheduled tasks can be started.'),
      );
    }

    final activeSessionResult =
        await _sessionRepository.getActiveSession(task.id);

    return activeSessionResult.match(
      Left.new,
      (activeSession) async {
        if (activeSession != null) {
          return const Left(
            ValidationFailure('Task already has an active session.'),
          );
        }

        final now = DateTime.now();

        final sessionResult = await _sessionRepository.createSession(
          TaskExecutionSession(
            id: 0,
            taskId: task.id,
            startedAt: now,
          ),
        );

        return sessionResult.match(
          Left.new,
          (_) async {
            final updatedTask = Task(
              id: task.id,
              activityId: task.activityId,
              title: task.title,
              description: task.description,
              status: TaskStatus.inProgress,
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