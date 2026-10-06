import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/data/models/activity_history_model.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';

class ActivityHistoryRepositoryImpl implements ActivityHistoryRepository {
  const ActivityHistoryRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, ActivityHistory>> createHistory(
    ActivityHistory history,
  ) async {
    try {
      final model = ActivityHistoryModel(
        id: history.id,
        taskId: history.taskId,
        activityId: history.activityId,
        taskTitle: history.taskTitle,
        plannedStart: history.plannedStart,
        plannedEnd: history.plannedEnd,
        outcome: history.outcome,
        occurredAt: history.occurredAt,
        actualDuration: history.actualDuration,
      );

      final id = await _database
          .into(_database.activityHistory)
          .insert(model.toCompanion());

      final data = await (_database.select(
        _database.activityHistory,
      )..where((table) => table.id.equals(id))).getSingle();

      return Right(ActivityHistoryModel.fromData(data));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ActivityHistory?>> getHistoryById(
    int id,
  ) async {
    try {
      final data = await (_database.select(
        _database.activityHistory,
      )..where((table) => table.id.equals(id))).getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(ActivityHistoryModel.fromData(data));
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityHistory>>> getHistory() async {
    try {
      final data = await _database.select(_database.activityHistory).get();

      return Right(
        data.map(ActivityHistoryModel.fromData).toList(),
      );
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityHistory>>> getHistoryByActivity(
    int activityId,
  ) async {
    try {
      final data = await (_database.select(
        _database.activityHistory,
      )..where(
          (table) => table.activityId.equals(activityId),
        )).get();

      return Right(
        data.map(ActivityHistoryModel.fromData).toList(),
      );
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityHistory>>> getHistoryByTask(
    int taskId,
  ) async {
    try {
      final data = await (_database.select(
        _database.activityHistory,
      )..where(
          (table) => table.taskId.equals(taskId),
        )).get();

      return Right(
        data.map(ActivityHistoryModel.fromData).toList(),
      );
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }
}