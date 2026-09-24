import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';

abstract interface class HabitOccurrenceRepository {
  Future<Either<Failure, HabitOccurrence>> createOccurrence(
    HabitOccurrence occurrence,
  );

  Future<Either<Failure, HabitOccurrence?>> getOccurrenceById(
    int id,
  );

  Future<Either<Failure, List<HabitOccurrence>>> getOccurrences();

  Future<Either<Failure, List<HabitOccurrence>>> getOccurrencesByHabit(
    int habitId,
  );

  Future<Either<Failure, HabitOccurrence>> updateOccurrence(
    HabitOccurrence occurrence,
  );

  Future<Either<Failure, Unit>> deleteOccurrence(
    int id,
  );
}