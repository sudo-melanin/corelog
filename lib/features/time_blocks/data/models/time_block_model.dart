import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';

class TimeBlockModel extends TimeBlock {
  const TimeBlockModel({
    required super.id,
    required super.projectId,
    required super.plannedStart,
    required super.plannedEnd,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.taskId,
    super.actualStart,
    super.actualEnd,
  });

  factory TimeBlockModel.fromData(db.TimeBlock data) {
    return TimeBlockModel(
      id: data.id,
      projectId: data.projectId,
      taskId: data.taskId,
      plannedStart: data.plannedStart,
      plannedEnd: data.plannedEnd,
      actualStart: data.actualStart,
      actualEnd: data.actualEnd,
      status: TimeBlockStatus.values.byName(data.status),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  db.TimeBlocksCompanion toCompanion() {
    return db.TimeBlocksCompanion.insert(
      projectId: projectId,
      taskId: Value(taskId),
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      actualStart: Value(actualStart),
      actualEnd: Value(actualEnd),
      status: status.name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}