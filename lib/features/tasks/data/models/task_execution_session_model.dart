import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';

class TaskExecutionSessionModel extends TaskExecutionSession {
  const TaskExecutionSessionModel({
    required super.id,
    required super.taskId,
    required super.startedAt,
    super.endedAt,
  });

  factory TaskExecutionSessionModel.fromData(
    db.TaskExecutionSession data,
  ) {
    return TaskExecutionSessionModel(
      id: data.id,
      taskId: data.taskId,
      startedAt: data.startedAt,
      endedAt: data.endedAt,
    );
  }

  db.TaskExecutionSessionsCompanion toCompanion() {
    return db.TaskExecutionSessionsCompanion.insert(
      taskId: taskId,
      startedAt: startedAt,
      endedAt: Value(endedAt),
    );
  }
}