import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/database.dart'as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/activities/data/models/activity_model.dart';
import 'package:corelog/features/activities/domain/entities/activity.dart';
import 'package:corelog/features/activities/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, Activity>> createActivity(
    Activity activity,
  ) async {
    try {
      final model = ActivityModel.fromEntity(activity);

      final id = await _database.into(_database.activities).insert(
            model.toCreateCompanion(),
          );

      final created = await _database.managers.activities
          .filter((row) => row.id.equals(id))
          .getSingle();

      return Right(ActivityModel.fromData(created));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.toString()));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Activity?>> getActivityById(int id) async {
    try {
      final activity = await (_database.select(_database.activities)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();

      if (activity == null) {
        return const Right(null);
      }

      return Right(ActivityModel.fromData(activity));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.toString()));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Activity>>> getActivities() async {
    try {
      final activities = await _database.select(_database.activities).get();

      return Right(
        activities.map(ActivityModel.fromData).toList(),
      );
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.toString()));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Activity>> updateActivity(
    Activity activity,
  ) async {
    try {
      final model = ActivityModel.fromEntity(activity);

      final updated = await _database.update(_database.activities).replace(
            model.toCompanion(),
          );

      if (!updated) {
        return const Left(
          DatabaseFailure('Activity could not be updated.'),
        );
      }

      return Right(activity);
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.toString()));
    }catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteActivity(int id) async {
    try {
      final deleted = await (_database.delete(_database.activities)
            ..where((table) => table.id.equals(id)))
          .go();

      if (deleted == 0) {
        return const Left(
          DatabaseFailure('Activity could not be deleted.'),
        );
      }

      return const Right(unit);
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.toString()));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }
}