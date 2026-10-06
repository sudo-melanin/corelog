import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.activityId,
    super.description,
    super.dueDate,
    super.completedAt,
    super.skippedAt,
    super.skipReason,
    super.skipNote,
    super.plannedStart,
    super.plannedEnd,

  });

  factory TaskModel.fromData(db.Task data) {
    return TaskModel(
      id: data.id,
      title: data.title,
      description: data.description,
      status: TaskStatus.values.byName(data.status),
      dueDate: data.dueDate,
      completedAt: data.completedAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      activityId: data.activityId,
      plannedStart: data.plannedStart,
      plannedEnd: data.plannedEnd,
      skippedAt: data.skippedAt,
      skipNote: data.skipNote,
      skipReason: data.skipReason == null
      ? null
      : TaskSkipReason.values.byName(data.skipReason!),
    );
  }

  db.TasksCompanion toCompanion() {
    return db.TasksCompanion.insert(
      activityId: Value(activityId),
      title: title,
      description: Value(description),
      status: status.name,
      dueDate: Value(dueDate),
      completedAt: Value(completedAt),
      createdAt: createdAt,
      updatedAt: updatedAt,
      plannedStart: Value(plannedStart),
      plannedEnd: Value(plannedEnd),
      skippedAt: Value(skippedAt),
      skipReason: Value(skipReason?.name),
      skipNote: Value(skipNote),
    );
  }
}
