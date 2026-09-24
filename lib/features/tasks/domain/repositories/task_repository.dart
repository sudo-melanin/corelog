import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';

abstract interface class TaskRepository {
  Future<Either<Failure, Task>> createTask(
    Task task,
  );

  Future<Either<Failure, Task?>> getTaskById(
    int id,
  );

  Future<Either<Failure, List<Task>>> getTasks();

  Future<Either<Failure, List<Task>>> getTasksByProject(
    int projectId,
  );

  Future<Either<Failure, Task>> updateTask(
    Task task,
  );

  Future<Either<Failure, Unit>> deleteTask(
    int id,
  );
}
