import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.projectId,
    super.description,
    super.dueDate,
    super.completedAt,
  });

  factory TaskModel.fromData(db.Task data) {
    return TaskModel(
      id: data.id,
      projectId: data.projectId,
      title: data.title,
      description: data.description,
      status: TaskStatus.values.byName(data.status),
      dueDate: data.dueDate,
      completedAt: data.completedAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  db.TasksCompanion toCompanion() {
    return db.TasksCompanion.insert(
      projectId: Value(projectId),
      title: title,
      description: Value(description),
      status: status.name,
      dueDate: Value(dueDate),
      completedAt: Value(completedAt),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}