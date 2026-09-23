import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';

class HabitOccurrenceModel extends HabitOccurrence {
  const HabitOccurrenceModel({
    required super.id,
    required super.habitId,
    required super.scheduledDate,
    required super.status,
    required super.createdAt,
    super.completedAt,
  });

  factory HabitOccurrenceModel.fromData(db.HabitOccurrence data) {
    return HabitOccurrenceModel(
      id: data.id,
      habitId: data.habitId,
      scheduledDate: data.scheduledDate,
      completedAt: data.completedAt,
      status: HabitOccurrenceStatus.values.byName(data.status),
      createdAt: data.createdAt,
    );
  }

  db.HabitOccurrencesCompanion toCompanion() {
    return db.HabitOccurrencesCompanion.insert(
      habitId: habitId,
      scheduledDate: scheduledDate,
      completedAt: Value(completedAt),
      status: status.name,
      createdAt: createdAt,
    );
  }
}