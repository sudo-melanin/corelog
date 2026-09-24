import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/data/models/task_model.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, Task>> createTask(
    Task task,
  ) async {
    try {
      final model = TaskModel(
        id: task.id,
        projectId: task.projectId,
        title: task.title,
        description: task.description,
        status: task.status,
        dueDate: task.dueDate,
        completedAt: task.completedAt,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

      final id = await _database.into(_database.tasks).insert(
            model.toCompanion(),
          );

      final data = await (_database.select(_database.tasks)
            ..where((table) => table.id.equals(id)))
          .getSingle();

      return Right(TaskModel.fromData(data));
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
  Future<Either<Failure, Task?>> getTaskById(
    int id,
  ) async {
    try {
      final data = await (_database.select(_database.tasks)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(TaskModel.fromData(data));
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
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final data = await _database.select(_database.tasks).get();

      final tasks = data
          .map(TaskModel.fromData)
          .map<Task>((model) => model)
          .toList();

      return Right(tasks);
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
  Future<Either<Failure, List<Task>>> getTasksByProject(
    int projectId,
  ) async {
    try {
      final data = await (_database.select(_database.tasks)
            ..where((table) => table.projectId.equals(projectId)))
          .get();

      final tasks = data
          .map(TaskModel.fromData)
          .map<Task>((model) => model)
          .toList();

      return Right(tasks);
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
  Future<Either<Failure, Task>> updateTask(
    Task task,
  ) async {
    try {
      final updated = await (_database.update(_database.tasks)
            ..where((table) => table.id.equals(task.id)))
          .write(
        db.TasksCompanion(
          projectId: Value(task.projectId),
          title: Value(task.title),
          description: Value(task.description),
          status: Value(task.status.name),
          dueDate: Value(task.dueDate),
          completedAt: Value(task.completedAt),
          createdAt: Value(task.createdAt),
          updatedAt: Value(task.updatedAt),
        ),
      );

      if (updated == 0) {
        return const Left(
          DatabaseFailure('Task not found.'),
        );
      }

      final data = await (_database.select(_database.tasks)
            ..where((table) => table.id.equals(task.id)))
          .getSingle();

      return Right(TaskModel.fromData(data));
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
  Future<Either<Failure, Unit>> deleteTask(
    int id,
  ) async {
    try {
      final deleted = await (_database.delete(_database.tasks)
            ..where((table) => table.id.equals(id)))
          .go();

      if (deleted == 0) {
        return const Left(
          DatabaseFailure('Task not found.'),
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