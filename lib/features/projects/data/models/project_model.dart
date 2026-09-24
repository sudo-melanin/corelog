import 'package:drift/drift.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/projects/domain/entities/project.dart';
import 'package:corelog/features/projects/domain/entities/project_status.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.description,
  });

  factory ProjectModel.fromData(db.Project data) {
    return ProjectModel(
      id: data.id,
      name: data.name,
      description: data.description,
      status: ProjectStatus.values.byName(data.status),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  db.ProjectsCompanion toCompanion() {
    return db.ProjectsCompanion.insert(
      name: name,
      description: Value(description),
      status: Value(status.name),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

