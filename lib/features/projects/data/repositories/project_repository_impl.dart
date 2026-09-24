import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/projects/data/models/project_model.dart';
import 'package:corelog/features/projects/domain/entities/project.dart';
import 'package:corelog/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, Project>> createProject(
    Project project,
  ) async {
    try {
      final model = ProjectModel(
        id: project.id,
        name: project.name,
        description: project.description,
        status: project.status,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
      );

      final id = await _database.into(_database.projects).insert(
            model.toCompanion(),
          );

      final data = await (_database.select(_database.projects)
            ..where((table) => table.id.equals(id)))
          .getSingle();

      return Right(ProjectModel.fromData(data));
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
  Future<Either<Failure, Project?>> getProjectById(
    int id,
  ) async {
    try {
      final data = await (_database.select(_database.projects)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();

      if (data == null) {
        return const Right(null);
      }

      return Right(ProjectModel.fromData(data));
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
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final data = await _database.select(_database.projects).get();

      final projects = data
          .map(ProjectModel.fromData)
          .map<Project>((model) => model)
          .toList();

      return Right(projects);
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
  Future<Either<Failure, Project>> updateProject(
    Project project,
  ) async {
    try {
      final updated = await (_database.update(_database.projects)
            ..where((table) => table.id.equals(project.id)))
          .write(
        db.ProjectsCompanion(
          name: Value(project.name),
          description: Value(project.description),
          status: Value(project.status.name),
          createdAt: Value(project.createdAt),
          updatedAt: Value(project.updatedAt),
        ),
      );

      if (updated == 0) {
        return const Left(
          DatabaseFailure('Project not found.'),
        );
      }

      final data = await (_database.select(_database.projects)
            ..where((table) => table.id.equals(project.id)))
          .getSingle();

      return Right(ProjectModel.fromData(data));
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
  Future<Either<Failure, Unit>> deleteProject(
    int id,
  ) async {
    try {
      final deleted = await (_database.delete(_database.projects)
            ..where((table) => table.id.equals(id)))
          .go();

      if (deleted == 0) {
        return const Left(
          DatabaseFailure('Project not found.'),
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