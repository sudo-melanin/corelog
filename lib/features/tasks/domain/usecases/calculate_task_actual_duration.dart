import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';

class CalculateTaskActualDuration {
  const CalculateTaskActualDuration(this._repository);

  final TaskExecutionSessionRepository _repository;

  Future<Either<Failure, Duration>> call(int taskId) async {
    final result = await _repository.getSessionsByTask(taskId);

    return result.map(
      (sessions) {
        var total = Duration.zero;

        for (final session in sessions) {
          final endedAt = session.endedAt;

          if (endedAt == null) {
            continue;
          }

          total += endedAt.difference(session.startedAt);
        }

        return total;
      },
    );
  }
}