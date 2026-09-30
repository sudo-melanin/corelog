import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/history/domain/entities/activity_history.dart';



class ActivityHistoryModel extends ActivityHistory {
  const ActivityHistoryModel({
    required super.id,
    required super.taskId,
    required super.taskTitle,
    required super.completedAt,
    required super.actualDuration,
    super.activityId,
    super.plannedStart,
    super.plannedEnd,
  });

  factory ActivityHistoryModel.fromData(
    db.ActivityHistoryData data,
  ) {
    return ActivityHistoryModel(
      id: data.id,
      taskId: data.taskId,
      activityId: data.activityId,
      taskTitle: data.taskTitle,
      plannedStart: data.plannedStart,
      plannedEnd: data.plannedEnd,
      completedAt: data.completedAt,
      actualDuration: Duration(
        minutes: data.actualDurationMinutes,
      ),
    );
  }

  db.ActivityHistoryCompanion toCompanion() {
    return db.ActivityHistoryCompanion.insert(
      taskId: taskId,
      activityId: Value(activityId),
      taskTitle: taskTitle,
      plannedStart: Value(plannedStart),
      plannedEnd: Value(plannedEnd),
      completedAt: completedAt,
      actualDurationMinutes: actualDuration.inMinutes,
    );
  }
}