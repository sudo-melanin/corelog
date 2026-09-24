import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class CompleteTask {
  const CompleteTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call(Task task) {
    final now = DateTime.now();

    final completedTask = Task(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: TaskStatus.completed,
      dueDate: task.dueDate,
      completedAt: now,
      createdAt: task.createdAt,
      updatedAt: now,
    );

    return _repository.updateTask(completedTask);
  }
}