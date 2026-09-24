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
    super.projectId,
    super.description,
    super.targetTime,
  });

  factory HabitModel.fromData(db.Habit data) {
    return HabitModel(
      id: data.id,
      projectId: data.projectId,
      name: data.name,
      description: data.description,
      weekdayMask: data.weekdayMask,
      targetTime: data.targetTime,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  db.HabitsCompanion toCompanion() {
    return db.HabitsCompanion.insert(
      projectId: Value(projectId),
      name: name,
      description: Value(description),
      weekdayMask: weekdayMask,
      targetTime: Value(targetTime),
      isActive: Value(isActive),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}