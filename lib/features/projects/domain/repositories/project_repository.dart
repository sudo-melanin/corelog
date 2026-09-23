import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/projects/domain/entities/project.dart';

abstract interface class ProjectRepository {
  Future<Either<Failure, Project>> createProject(
    Project project,
  );

  Future<Either<Failure, Project?>> getProjectById(
    int id,
  );

  Future<Either<Failure, List<Project>>> getProjects();

  Future<Either<Failure, Project>> updateProject(
    Project project,
  );

  Future<Either<Failure, Unit>> deleteProject(
    int id,
  );
}