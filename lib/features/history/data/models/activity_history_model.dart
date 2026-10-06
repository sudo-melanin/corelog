import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';

class ActivityHistoryModel extends ActivityHistory {
  const ActivityHistoryModel({
    required super.id,
    required super.taskId,
    required super.taskTitle,
    required super.outcome,
    required super.occurredAt,
    required super.actualDuration,
    super.activityId,
    super.plannedStart,
    super.plannedEnd,
    super.skipReason,
    super.skipNote,
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
      outcome: HistoryOutcome.values.byName(data.outcome),
      occurredAt: data.occurredAt,
      actualDuration: Duration(
        minutes: data.actualDurationMinutes,
      ),
      skipReason: data.skipReason == null
          ? null
          : TaskSkipReason.values.byName(data.skipReason!),
      skipNote: data.skipNote,
    );
  }

  db.ActivityHistoryCompanion toCompanion() {
    return db.ActivityHistoryCompanion.insert(
      taskId: taskId,
      activityId: Value(activityId),
      taskTitle: taskTitle,
      plannedStart: Value(plannedStart),
      plannedEnd: Value(plannedEnd),
      outcome: outcome.name,
      occurredAt: occurredAt,
      actualDurationMinutes: actualDuration.inMinutes,
      skipReason: Value(skipReason?.name),
      skipNote: Value(skipNote),
    );
  }
}