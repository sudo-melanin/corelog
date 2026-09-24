import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';

abstract interface class HabitRepository {
  Future<Either<Failure, Habit>> createHabit(
    Habit habit,
  );

  Future<Either<Failure, Habit?>> getHabitById(
    int id,
  );

  Future<Either<Failure, List<Habit>>> getHabits();

  Future<Either<Failure, Habit>> updateHabit(
    Habit habit,
  );

  Future<Either<Failure, Unit>> deleteHabit(
    int id,
  );
}