import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/time_blocks/data/models/time_block_model.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';

class TimeBlockRepositoryImpl implements TimeBlockRepository {
  const TimeBlockRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, TimeBlock>> createTimeBlock(
    TimeBlock timeBlock,
  ) async {
    try {
      final model = TimeBlockModel(
        id: timeBlock.id,
        projectId: timeBlock.projectId,
        taskId: timeBlock.taskId,
        plannedStart: timeBlock.plannedStart,
        plannedEnd: timeBlock.plannedEnd,
        actualStart: timeBlock.actualStart,
        actualEnd: timeBlock.actualEnd,
        status: timeBlock.status,
        createdAt: timeBlock.createdAt,
        updatedAt: timeBlock.updatedAt,
      );

      final id = await _database.into(_database.timeBlocks).insert(
            model.toCompanion(),
          );

      final data = await (_database.select(_database.timeBlocks)
            ..where((table) => table.id.equals(id)))
          .getSingle();

      return Right(TimeBlockModel.fromData(data));
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
  Future<Either<Failure, TimeBlock?>> getTimeBlockById(
    int id,
  ) async {
    try {
      final data = await (_database.select(_database.timeBlocks)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(TimeBlockModel.fromData(data));
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
  Future<Either<Failure, List<TimeBlock>>> getTimeBlocks() async {
    try {
      final data = await _database.select(_database.timeBlocks).get();

      final timeBlocks = data
          .map(TimeBlockModel.fromData)
          .map<TimeBlock>((model) => model)
          .toList();

      return Right(timeBlocks);
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
  Future<Either<Failure, List<TimeBlock>>> getTimeBlocksByProject(
    int projectId,
  ) async {
    try {
      final data = await (_database.select(_database.timeBlocks)
            ..where((table) => table.projectId.equals(projectId)))
          .get();

      final timeBlocks = data
          .map(TimeBlockModel.fromData)
          .map<TimeBlock>((model) => model)
          .toList();

      return Right(timeBlocks);
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
  Future<Either<Failure, List<TimeBlock>>> getTimeBlocksByTask(
    int taskId,
  ) async {
    try {
      final data = await (_database.select(_database.timeBlocks)
            ..where((table) => table.taskId.equals(taskId)))
          .get();

      final timeBlocks = data
          .map(TimeBlockModel.fromData)
          .map<TimeBlock>((model) => model)
          .toList();

      return Right(timeBlocks);
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
  Future<Either<Failure, TimeBlock>> updateTimeBlock(
    TimeBlock timeBlock,
  ) async {
    try {
      final updated = await (_database.update(_database.timeBlocks)
            ..where((table) => table.id.equals(timeBlock.id)))
          .write(
        db.TimeBlocksCompanion(
          projectId: Value(timeBlock.projectId),
          taskId: Value(timeBlock.taskId),
          plannedStart: Value(timeBlock.plannedStart),
          plannedEnd: Value(timeBlock.plannedEnd),
          actualStart: Value(timeBlock.actualStart),
          actualEnd: Value(timeBlock.actualEnd),
          status: Value(timeBlock.status.name),
          createdAt: Value(timeBlock.createdAt),
          updatedAt: Value(timeBlock.updatedAt),
        ),
      );

      if (updated == 0) {
        return const Left(
          DatabaseFailure('Time block not found.'),
        );
      }

      final data = await (_database.select(_database.timeBlocks)
            ..where((table) => table.id.equals(timeBlock.id)))
          .getSingle();

      return Right(TimeBlockModel.fromData(data));
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
  Future<Either<Failure, Unit>> deleteTimeBlock(
    int id,
  ) async {
    try {
      final deleted = await (_database.delete(_database.timeBlocks)
            ..where((table) => table.id.equals(id)))
          .go();

      if (deleted == 0) {
        return const Left(
          DatabaseFailure('Time block not found.'),
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