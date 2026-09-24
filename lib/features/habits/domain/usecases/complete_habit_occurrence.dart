import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';

class CompleteHabitOccurrence {
  const CompleteHabitOccurrence(this._repository);

  final HabitOccurrenceRepository _repository;

  Future<Either<Failure, HabitOccurrence>> call(
    HabitOccurrence occurrence,
  ) {
    final now = DateTime.now();

    final completedOccurrence = HabitOccurrence(
      id: occurrence.id,
      habitId: occurrence.habitId,
      scheduledDate: occurrence.scheduledDate,
      completedAt: now,
      status: HabitOccurrenceStatus.completed,
      createdAt: occurrence.createdAt,
    );

    return _repository.updateOccurrence(completedOccurrence);
  }
}