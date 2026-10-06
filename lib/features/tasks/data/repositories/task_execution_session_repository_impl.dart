import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/data/models/task_execution_session_model.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';

class TaskExecutionSessionRepositoryImpl
    implements TaskExecutionSessionRepository {
  const TaskExecutionSessionRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, TaskExecutionSession>> createSession(
    TaskExecutionSession session,
  ) async {
    try {
      final model = TaskExecutionSessionModel(
        id: session.id,
        taskId: session.taskId,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
      );

      final id = await _database
          .into(_database.taskExecutionSessions)
          .insert(model.toCompanion());

      final data = await (_database.select(
        _database.taskExecutionSessions,
      )..where((table) => table.id.equals(id))).getSingle();

      return Right(TaskExecutionSessionModel.fromData(data));
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
  Future<Either<Failure, TaskExecutionSession?>> getActiveSession(
    int taskId,
  ) async {
    try {
      final data = await (_database.select(
        _database.taskExecutionSessions,
      )..where(
          (table) =>
              table.taskId.equals(taskId) & table.endedAt.isNull(),
        )).getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(TaskExecutionSessionModel.fromData(data));
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
  Future<Either<Failure, List<TaskExecutionSession>>> getSessionsByTask(
    int taskId,
  ) async {
    try {
      final data = await (_database.select(
        _database.taskExecutionSessions,
      )..where(
          (table) => table.taskId.equals(taskId),
        )).get();

      return Right(
        data.map(TaskExecutionSessionModel.fromData).toList(),
      );
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
  Future<Either<Failure, TaskExecutionSession>> endSession(
    TaskExecutionSession session,
  ) async {
    try {
      final updated = await (_database.update(
        _database.taskExecutionSessions,
      )..where(
          (table) => table.id.equals(session.id),
        )).write(
        db.TaskExecutionSessionsCompanion(
          taskId: Value(session.taskId),
          startedAt: Value(session.startedAt),
          endedAt: Value(session.endedAt),
        ),
      );

      if (updated == 0) {
        return const Left(
          DatabaseFailure('Execution session not found.'),
        );
      }

      final data = await (_database.select(
        _database.taskExecutionSessions,
      )..where(
          (table) => table.id.equals(session.id),
        )).getSingle();

      return Right(TaskExecutionSessionModel.fromData(data));
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