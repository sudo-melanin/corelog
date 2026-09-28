import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/habits/domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.name,
    required super.weekdayMask,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.activityId,
    super.description,
    super.targetTime,
    super.targetDuration,
  });

  factory HabitModel.fromData(db.Habit data) {
    return HabitModel(
      id: data.id,
      activityId: data.activityId,
      name: data.name,
      description: data.description,
      weekdayMask: data.weekdayMask,
      targetTime: data.targetTime,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      targetDuration: data.targetDurationMinutes == null
          ? null
          : Duration(minutes: data.targetDurationMinutes!),
    );
  }

  db.HabitsCompanion toCompanion() {
    return db.HabitsCompanion.insert(
      activityId: Value(activityId),
      name: name,
      description: Value(description),
      weekdayMask: weekdayMask,
      targetTime: Value(targetTime),
      isActive: Value(isActive),
      createdAt: createdAt,
      updatedAt: updatedAt,
      targetDurationMinutes: Value(targetDuration?.inMinutes),
    );
  }
}
