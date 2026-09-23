import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/projects/data/repositories/project_repository_impl.dart';
import 'package:corelog/features/projects/domain/entities/project.dart';
import 'package:corelog/features/projects/domain/entities/project_status.dart';

void main() {
  late db.AppDatabase database;
  late ProjectRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = ProjectRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ProjectRepositoryImpl', () {
    test('createProject persists and returns the created project', () async {
      final project = Project(
        id: 0,
        name: 'CoreLog',
        description: 'CoreLog development',
        status: ProjectStatus.active,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final result = await repository.createProject(project);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (created) {
          expect(created.id, isPositive);
          expect(created.name, 'CoreLog');
          expect(created.description, 'CoreLog development');
          expect(created.status, ProjectStatus.active);
          expect(created.createdAt, project.createdAt);
          expect(created.updatedAt, project.updatedAt);
        },
      );

      final rows = await database.select(database.projects).get();

      expect(rows, hasLength(1));
      expect(rows.first.name, 'CoreLog');
    });

    test('getProjectById returns the project when it exists', () async {
      final now = DateTime.now();

      final id = await database.into(database.projects).insert(
            db.ProjectsCompanion.insert(
              name: 'CoreLog',
              description: const Value('Development'),
              status: const Value('active'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final result = await repository.getProjectById(id);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (project) {
          expect(project, isNotNull);
          expect(project!.id, id);
          expect(project.name, 'CoreLog');
          expect(project.status, ProjectStatus.active);
        },
      );
    });

    test('getProjectById returns null when project does not exist',
        () async {
      final result = await repository.getProjectById(999);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (project) => expect(project, isNull),
      );
    });

    test('getProjects returns all projects', () async {
      final now = DateTime.now();

      await database.into(database.projects).insert(
            db.ProjectsCompanion.insert(
              name: 'CoreLog',
              status: const Value('active'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database.into(database.projects).insert(
            db.ProjectsCompanion.insert(
              name: 'FitLink',
              status: const Value('completed'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final result = await repository.getProjects();

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (projects) {
          expect(projects, hasLength(2));
          expect(projects.map((project) => project.name), contains('CoreLog'));
          expect(projects.map((project) => project.name), contains('FitLink'));
        },
      );
    });

    test('updateProject updates and returns the project', () async {
      final now = DateTime(2026, 1, 1, 10);

      final id = await database.into(database.projects).insert(
            db.ProjectsCompanion.insert(
              name: 'CoreLog',
              description: const Value('Original description'),
              status: const Value('active'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final updatedProject = Project(
        id: id,
        name: 'CoreLog 2.0',
        description: 'Updated description',
        status: ProjectStatus.completed,
        createdAt: now,
        updatedAt: now.add(const Duration(minutes: 5)),
      );

      final result = await repository.updateProject(updatedProject);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (project) {
          expect(project.id, id);
          expect(project.name, 'CoreLog 2.0');
          expect(project.description, 'Updated description');
          expect(project.status, ProjectStatus.completed);
          expect(project.updatedAt, updatedProject.updatedAt);
        },
      );

      final row = await (database.select(database.projects)
            ..where((table) => table.id.equals(id)))
          .getSingle();

      expect(row.name, 'CoreLog 2.0');
      expect(row.status, 'completed');
    });

    test('updateProject returns DatabaseFailure when project does not exist',
        () async {
      final project = Project(
        id: 999,
        name: 'Missing Project',
        status: ProjectStatus.active,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final result = await repository.updateProject(project);

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Project not found.');
        },
        (_) => fail('Expected a failure.'),
      );
    });

    test('deleteProject removes the project', () async {
      final now = DateTime.now();

      final id = await database.into(database.projects).insert(
            db.ProjectsCompanion.insert(
              name: 'CoreLog',
              status: const Value('active'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final result = await repository.deleteProject(id);

      expect(result.isRight(), isTrue);

      final rows = await database.select(database.projects).get();

      expect(rows, isEmpty);
    });

    test('deleteProject returns DatabaseFailure when project does not exist',
        () async {
      final result = await repository.deleteProject(999);

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Project not found.');
        },
        (_) => fail('Expected a failure.'),
      );
    });
  });
}