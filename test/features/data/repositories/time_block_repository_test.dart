import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/projects/data/repositories/project_repository_impl.dart';
import 'package:corelog/features/projects/domain/entities/project.dart';
import 'package:corelog/features/projects/domain/entities/project_status.dart';
import 'package:corelog/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/time_blocks/data/repositories/time_block_repository_impl.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';

void main() {
  late db.AppDatabase database;
  late TimeBlockRepositoryImpl repository;
  late ProjectRepositoryImpl projectRepository;
  late TaskRepositoryImpl taskRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = TimeBlockRepositoryImpl(database);
    projectRepository = ProjectRepositoryImpl(database);
    taskRepository = TaskRepositoryImpl(database);
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

  Future<Task> createTask(int projectId) async {
    final now = DateTime(2026, 1, 1, 10);

    final result = await taskRepository.createTask(
      Task(
        id: 0,
        projectId: projectId,
        title: 'Time block task',
        description: null,
        status: TaskStatus.pending,
        dueDate: null,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return result.match(
      (failure) => throw TestFailure(failure.message),
      (task) => task,
    );
  }

  TimeBlock createTimeBlock({
    required int projectId,
    int? taskId,
    String status = 'planned',
  }) {
    final start = DateTime(2026, 1, 1, 10);
    final end = DateTime(2026, 1, 1, 11);

    return TimeBlock(
      id: 0,
      projectId: projectId,
      taskId: taskId,
      plannedStart: start,
      plannedEnd: end,
      actualStart: null,
      actualEnd: null,
      status: TimeBlockStatus.values.byName(status),
      createdAt: start,
      updatedAt: start,
    );
  }

  test('createTimeBlock creates and returns a time block', () async {
    final project = await createProject();

    final result = await repository.createTimeBlock(
      createTimeBlock(projectId: project.id),
    );

    result.match(
      (failure) => fail(failure.message),
      (timeBlock) {
        expect(timeBlock.id, greaterThan(0));
        expect(timeBlock.projectId, project.id);
        expect(timeBlock.status, TimeBlockStatus.planned);
      },
    );
  });

  test('getTimeBlockById returns the time block when it exists', () async {
    final project = await createProject();

    final created = await repository.createTimeBlock(
      createTimeBlock(projectId: project.id),
    );

    final timeBlock = created.match(
      (failure) => throw TestFailure(failure.message),
      (timeBlock) => timeBlock,
    );

    final result = await repository.getTimeBlockById(timeBlock.id);

    result.match(
      (failure) => fail(failure.message),
      (found) {
        expect(found, isNotNull);
        expect(found!.id, timeBlock.id);
        expect(found.projectId, project.id);
      },
    );
  });

  test('getTimeBlockById returns null when it does not exist', () async {
    final result = await repository.getTimeBlockById(999);

    result.match(
      (failure) => fail(failure.message),
      (timeBlock) => expect(timeBlock, isNull),
    );
  });

  test('getTimeBlocks returns all time blocks', () async {
    final project = await createProject();

    await repository.createTimeBlock(
      createTimeBlock(projectId: project.id),
    );

    await repository.createTimeBlock(
      createTimeBlock(projectId: project.id),
    );

    final result = await repository.getTimeBlocks();

    result.match(
      (failure) => fail(failure.message),
      (timeBlocks) => expect(timeBlocks, hasLength(2)),
    );
  });

  test('getTimeBlocksByProject returns only blocks for the project',
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

    await repository.createTimeBlock(
      createTimeBlock(projectId: firstProject.id),
    );

    await repository.createTimeBlock(
      createTimeBlock(projectId: secondProject.id),
    );

    final result = await repository.getTimeBlocksByProject(firstProject.id);

    result.match(
      (failure) => fail(failure.message),
      (timeBlocks) {
        expect(timeBlocks, hasLength(1));
        expect(timeBlocks.first.projectId, firstProject.id);
      },
    );
  });

  test('getTimeBlocksByTask returns only blocks for the task', () async {
    final project = await createProject();
    final firstTask = await createTask(project.id);
    final secondTask = await createTask(project.id);

    await repository.createTimeBlock(
      createTimeBlock(
        projectId: project.id,
        taskId: firstTask.id,
      ),
    );

    await repository.createTimeBlock(
      createTimeBlock(
        projectId: project.id,
        taskId: secondTask.id,
      ),
    );

    final result = await repository.getTimeBlocksByTask(firstTask.id);

    result.match(
      (failure) => fail(failure.message),
      (timeBlocks) {
        expect(timeBlocks, hasLength(1));
        expect(timeBlocks.first.taskId, firstTask.id);
      },
    );
  });

  test('updateTimeBlock updates and returns the time block', () async {
    final project = await createProject();

    final created = await repository.createTimeBlock(
      createTimeBlock(projectId: project.id),
    );

    final timeBlock = created.match(
      (failure) => throw TestFailure(failure.message),
      (timeBlock) => timeBlock,
    );

    final updated = TimeBlock(
      id: timeBlock.id,
      projectId: timeBlock.projectId,
      taskId: null,
      plannedStart: DateTime(2026, 1, 1, 11),
      plannedEnd: DateTime(2026, 1, 1, 12),
      actualStart: DateTime(2026, 1, 1, 11),
      actualEnd: DateTime(2026, 1, 1, 12),
      status: TimeBlockStatus.completed,
      createdAt: timeBlock.createdAt,
      updatedAt: DateTime(2026, 1, 1, 12),
    );

    final result = await repository.updateTimeBlock(updated);

    result.match(
      (failure) => fail(failure.message),
      (timeBlock) {
        expect(timeBlock.id, updated.id);
        expect(timeBlock.status, TimeBlockStatus.completed);
        expect(timeBlock.actualStart, updated.actualStart);
        expect(timeBlock.actualEnd, updated.actualEnd);
      },
    );
  });

  test('updateTimeBlock returns failure when it does not exist', () async {
    final result = await repository.updateTimeBlock(
      TimeBlock(
        id: 999,
        projectId: 1,
        plannedStart: DateTime(2026, 1, 1, 10),
        plannedEnd: DateTime(2026, 1, 1, 11),
        status: TimeBlockStatus.planned,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      ),
    );

    result.match(
      (failure) => expect(failure.message, 'Time block not found.'),
      (_) => fail('Expected updateTimeBlock to fail.'),
    );
  });

  test('deleteTimeBlock deletes an existing time block', () async {
    final project = await createProject();

    final created = await repository.createTimeBlock(
      createTimeBlock(projectId: project.id),
    );

    final timeBlock = created.match(
      (failure) => throw TestFailure(failure.message),
      (timeBlock) => timeBlock,
    );

    final result = await repository.deleteTimeBlock(timeBlock.id);

    result.match(
      (failure) => fail(failure.message),
      (_) {},
    );

    final lookup = await repository.getTimeBlockById(timeBlock.id);

    lookup.match(
      (failure) => fail(failure.message),
      (found) => expect(found, isNull),
    );
  });

  test('deleteTimeBlock returns failure when it does not exist', () async {
    final result = await repository.deleteTimeBlock(999);

    result.match(
      (failure) => expect(failure.message, 'Time block not found.'),
      (_) => fail('Expected deleteTimeBlock to fail.'),
    );
  });
}