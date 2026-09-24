import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/data/models/habit_model.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, Habit>> createHabit(
    Habit habit,
  ) async {
    try {
      final model = HabitModel(
        id: habit.id,
        projectId: habit.projectId,
        name: habit.name,
        description: habit.description,
        weekdayMask: habit.weekdayMask,
        targetTime: habit.targetTime,
        isActive: habit.isActive,
        createdAt: habit.createdAt,
        updatedAt: habit.updatedAt,
      );

      final id = await _database.into(_database.habits).insert(
            model.toCompanion(),
          );

      final data = await (_database.select(_database.habits)
            ..where((table) => table.id.equals(id)))
          .getSingle();

      return Right(HabitModel.fromData(data));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on InvalidDataException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on SqliteException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit?>> getHabitById(
    int id,
  ) async {
    try {
      final data = await (_database.select(_database.habits)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(HabitModel.fromData(data));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on InvalidDataException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on SqliteException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Habit>>> getHabits() async {
    try {
      final data = await _database.select(_database.habits).get();

      final habits = data
          .map(HabitModel.fromData)
          .map<Habit>((model) => model)
          .toList();

      return Right(habits);
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on InvalidDataException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on SqliteException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(
    Habit habit,
  ) async {
    try {
      final updated = await (_database.update(_database.habits)
            ..where((table) => table.id.equals(habit.id)))
          .write(
        db.HabitsCompanion(
          projectId: Value(habit.projectId),
          name: Value(habit.name),
          description: Value(habit.description),
          weekdayMask: Value(habit.weekdayMask),
          targetTime: Value(habit.targetTime),
          isActive: Value(habit.isActive),
          createdAt: Value(habit.createdAt),
          updatedAt: Value(habit.updatedAt),
        ),
      );

      if (updated == 0) {
        return const Left(
          DatabaseFailure('Habit not found.'),
        );
      }

      final data = await (_database.select(_database.habits)
            ..where((table) => table.id.equals(habit.id)))
          .getSingle();

      return Right(HabitModel.fromData(data));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on InvalidDataException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on SqliteException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHabit(
    int id,
  ) async {
    try {
      final deleted = await (_database.delete(_database.habits)
            ..where((table) => table.id.equals(id)))
          .go();

      if (deleted == 0) {
        return const Left(
          DatabaseFailure('Habit not found.'),
        );
      }

      return const Right(unit);
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on InvalidDataException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on SqliteException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }
}