import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class SkipTask {
  const SkipTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Task>> call({
    required Task task,
    required TaskSkipReason reason,
    String? note,
  }) async{
    if (task.status != TaskStatus.pending) {
      return const Left(
        ValidationFailure(
          'Only pending tasks can be skipped.',
        ),
      );
    }

    final now = DateTime.now();

    final skippedTask = Task(
      id: task.id,
      activityId: task.activityId,
      title: task.title,
      description: task.description,
      status: TaskStatus.skipped,
      dueDate: task.dueDate,
      plannedStart: task.plannedStart,
      plannedEnd: task.plannedEnd,
      completedAt: task.completedAt,
      skippedAt: now,
      skipReason: reason,
      skipNote: note,
      createdAt: task.createdAt,
      updatedAt: now,
    );

    return _repository.updateTask(skippedTask);
  }
}