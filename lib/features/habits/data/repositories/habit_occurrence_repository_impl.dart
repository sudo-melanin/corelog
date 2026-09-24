import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/data/models/habit_occurrence_model.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';

class HabitOccurrenceRepositoryImpl
    implements HabitOccurrenceRepository {
  const HabitOccurrenceRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, HabitOccurrence>> createOccurrence(
    HabitOccurrence occurrence,
  ) async {
    try {
      final model = HabitOccurrenceModel(
        id: occurrence.id,
        habitId: occurrence.habitId,
        scheduledDate: occurrence.scheduledDate,
        completedAt: occurrence.completedAt,
        status: occurrence.status,
        createdAt: occurrence.createdAt,
      );

      final id = await _database.into(_database.habitOccurrences).insert(
            model.toCompanion(),
          );

      final data = await (_database.select(_database.habitOccurrences)
            ..where((table) => table.id.equals(id)))
          .getSingle();

      return Right(HabitOccurrenceModel.fromData(data));
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
  Future<Either<Failure, HabitOccurrence?>> getOccurrenceById(
    int id,
  ) async {
    try {
      final data = await (_database.select(_database.habitOccurrences)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(HabitOccurrenceModel.fromData(data));
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
  Future<Either<Failure, List<HabitOccurrence>>> getOccurrences() async {
    try {
      final data =
          await _database.select(_database.habitOccurrences).get();

      final occurrences = data
          .map(HabitOccurrenceModel.fromData)
          .map<HabitOccurrence>((model) => model)
          .toList();

      return Right(occurrences);
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
  Future<Either<Failure, List<HabitOccurrence>>>
      getOccurrencesByHabit(
    int habitId,
  ) async {
    try {
      final data = await (_database.select(_database.habitOccurrences)
            ..where((table) => table.habitId.equals(habitId)))
          .get();

      final occurrences = data
          .map(HabitOccurrenceModel.fromData)
          .map<HabitOccurrence>((model) => model)
          .toList();

      return Right(occurrences);
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
  Future<Either<Failure, HabitOccurrence>> updateOccurrence(
    HabitOccurrence occurrence,
  ) async {
    try {
      final updated = await (_database.update(_database.habitOccurrences)
            ..where((table) => table.id.equals(occurrence.id)))
          .write(
        db.HabitOccurrencesCompanion(
          habitId: Value(occurrence.habitId),
          scheduledDate: Value(occurrence.scheduledDate),
          completedAt: Value(occurrence.completedAt),
          status: Value(occurrence.status.name),
          createdAt: Value(occurrence.createdAt),
        ),
      );

      if (updated == 0) {
        return const Left(
          DatabaseFailure('Habit occurrence not found.'),
        );
      }

      final data = await (_database.select(_database.habitOccurrences)
            ..where((table) => table.id.equals(occurrence.id)))
          .getSingle();

      return Right(HabitOccurrenceModel.fromData(data));
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
  Future<Either<Failure, Unit>> deleteOccurrence(
    int id,
  ) async {
    try {
      final deleted = await (_database.delete(_database.habitOccurrences)
            ..where((table) => table.id.equals(id)))
          .go();

      if (deleted == 0) {
        return const Left(
          DatabaseFailure('Habit occurrence not found.'),
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