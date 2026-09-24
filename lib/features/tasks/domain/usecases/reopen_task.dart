import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class ReopenTask {
  const ReopenTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(Task task) {
    final now = DateTime.now();

    final reopenedTask = Task(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: TaskStatus.pending,
      dueDate: task.dueDate,
      completedAt: null,
      createdAt: task.createdAt,
      updatedAt: now,
    );

    return _repository.updateTask(reopenedTask);
  }
}