import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';

abstract interface class TaskExecutionSessionRepository {
  Future<Either<Failure, TaskExecutionSession>> createSession(
    TaskExecutionSession session,
  );

  Future<Either<Failure, TaskExecutionSession?>> getActiveSession(
    int taskId,
  );

  Future<Either<Failure, List<TaskExecutionSession>>> getSessionsByTask(
    int taskId,
  );

  Future<Either<Failure, TaskExecutionSession>> endSession(
    TaskExecutionSession session,
  );
}