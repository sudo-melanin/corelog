import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/projects/data/repositories/project_repository_impl.dart';
import 'package:corelog/features/projects/domain/entities/project.dart';
import 'package:corelog/features/projects/domain/entities/project_status.dart';
import 'package:corelog/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';

void main() {
  late db.AppDatabase database;
  late TaskRepositoryImpl repository;
  late ProjectRepositoryImpl projectRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = TaskRepositoryImpl(database);
    projectRepository = ProjectRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<Project> createProject() async {
    final now = DateTime(2026, 1, 1, 10);

    final result = await projectRepository.createProject(
      Project(
        id: 0,
        name: 'CoreLog',
        description: 'CoreLog development',
        status: ProjectStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return result.match(
      (failure) => throw TestFailure(failure.message),
      (project) => project,
    );
  }

  Task createTask({
    required int projectId,
    String title = 'Build task repository',
    TaskStatus status = TaskStatus.pending,
  }) {
    final now = DateTime(2026, 1, 1, 10);

    return Task(
      id: 0,
      projectId: projectId,
      title: title,
      description: 'Repository test task',
      status: status,
      dueDate: DateTime(2026, 1, 2, 10),
      completedAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('createTask creates and returns a task', () async {
    final project = await createProject();

    final result = await repository.createTask(
      createTask(projectId: project.id),
    );

    result.match(
      (failure) => fail(failure.message),
      (task) {
        expect(task.id, greaterThan(0));
        expect(task.projectId, project.id);
        expect(task.title, 'Build task repository');
        expect(task.status, TaskStatus.pending);
      },
    );
  });

  test('getTaskById returns the task when it exists', () async {
    final project = await createProject();

    final created = await repository.createTask(
      createTask(projectId: project.id),
    );

    final task = created.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );

    final result = await repository.getTaskById(task.id);

    result.match(
      (failure) => fail(failure.message),
      (found) {
        expect(found, isNotNull);
        expect(found!.id, task.id);
        expect(found.title, task.title);
      },
    );
  });

  test('getTaskById returns null when the task does not exist', () async {
    final result = await repository.getTaskById(999);

    result.match(
      (failure) => fail(failure.message),
      (task) => expect(task, isNull),
    );
  });

  test('getTasks returns all tasks', () async {
    final project = await createProject();

    await repository.createTask(
      createTask(
        projectId: project.id,
        title: 'Task one',
      ),
    );

    await repository.createTask(
      createTask(
        projectId: project.id,
        title: 'Task two',
      ),
    );

    final result = await repository.getTasks();

    result.match(
      (failure) => fail(failure.message),
      (tasks) {
        expect(tasks, hasLength(2));
        expect(tasks.map((task) => task.title), containsAll([
          'Task one',
          'Task two',
        ]));
      },
    );
  });

  test('getTasksByProject returns only tasks for the requested project',
      () async {
    final firstProject = await createProject();

    final secondProjectResult = await projectRepository.createProject(
      Project(
        id: 0,
        name: 'FitLink',
        description: null,
        status: ProjectStatus.active,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      ),
    );

    final secondProject = secondProjectResult.match(
      (failure) => throw TestFailure(failure.message),
      (project) => project,
    );

    await repository.createTask(
      createTask(
        projectId: firstProject.id,
        title: 'First project task',
      ),
    );

    await repository.createTask(
      createTask(
        projectId: secondProject.id,
        title: 'Second project task',
      ),
    );

    final result = await repository.getTasksByProject(firstProject.id);

    result.match(
      (failure) => fail(failure.message),
      (tasks) {
        expect(tasks, hasLength(1));
        expect(tasks.first.title, 'First project task');
        expect(tasks.first.projectId, firstProject.id);
      },
    );
  });

  test('updateTask updates and returns the task', () async {
    final project = await createProject();

    final created = await repository.createTask(
      createTask(projectId: project.id),
    );

    final task = created.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );

    final updatedTask = Task(
      id: task.id,
      projectId: task.projectId,
      title: 'Updated task',
      description: 'Updated description',
      status: TaskStatus.inProgress,
      dueDate: DateTime(2026, 1, 3, 10),
      completedAt: null,
      createdAt: task.createdAt,
      updatedAt: DateTime(2026, 1, 2, 10),
    );

    final result = await repository.updateTask(updatedTask);

    result.match(
      (failure) => fail(failure.message),
      (updated) {
        expect(updated.id, task.id);
        expect(updated.title, 'Updated task');
        expect(updated.status, TaskStatus.inProgress);
        expect(updated.description, 'Updated description');
      },
    );
  });

  test('updateTask returns failure when task does not exist', () async {
    final result = await repository.updateTask(
      Task(
        id: 999,
        projectId: null,
        title: 'Missing task',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      ),
    );

    result.match(
      (failure) => expect(failure.message, 'Task not found.'),
      (_) => fail('Expected updateTask to fail.'),
    );
  });

  test('deleteTask deletes an existing task', () async {
    final project = await createProject();

    final created = await repository.createTask(
      createTask(projectId: project.id),
    );

    final task = created.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );

    final result = await repository.deleteTask(task.id);

    result.match(
      (failure) => fail(failure.message),
      (_) {},
    );

    final lookup = await repository.getTaskById(task.id);

    lookup.match(
      (failure) => fail(failure.message),
      (found) => expect(found, isNull),
    );
  });

  test('deleteTask returns failure when task does not exist', () async {
    final result = await repository.deleteTask(999);

    result.match(
      (failure) => expect(failure.message, 'Task not found.'),
      (_) => fail('Expected deleteTask to fail.'),
    );
  });
}