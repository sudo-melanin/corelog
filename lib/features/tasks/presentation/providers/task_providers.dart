import 'package:corelog/features/tasks/domain/usecases/resume_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/usecases.dart';
import 'package:corelog/features/tasks/data/repositories/task_execution_session_repository_impl.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TaskRepositoryImpl(database);
});

final completeTaskProvider = Provider<CompleteTask>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final sessionRepository = ref.watch(taskExecutionSessionRepositoryProvider);

  return CompleteTask(
    taskRepository: taskRepository,
    sessionRepository: sessionRepository);
});

final taskExecutionSessionRepositoryProvider =
    Provider<TaskExecutionSessionRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TaskExecutionSessionRepositoryImpl(database);
});

final reopenTaskProvider = Provider<ReopenTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return ReopenTask(repository);
});

final skipTaskProvider = Provider<SkipTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return SkipTask(repository);
});

final startTaskProvider = Provider<StartTask>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final sessionRepository = ref.watch(
    taskExecutionSessionRepositoryProvider,
  );

  return StartTask(
    taskRepository: taskRepository,
    sessionRepository: sessionRepository,
  );
});

final pauseTaskProvider = Provider<PauseTask>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final sessionRepository = ref.watch(
    taskExecutionSessionRepositoryProvider,
  );

  return PauseTask(
    taskRepository: taskRepository,
    sessionRepository: sessionRepository,
  );
});

final resumeTaskProvider = Provider<ResumeTask>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final sessionRepository = ref.watch(
    taskExecutionSessionRepositoryProvider,
  );

  return ResumeTask(
    taskRepository: taskRepository,
    sessionRepository: sessionRepository,
  );
});

final calculateTaskActualDurationProvider =
    Provider<CalculateTaskActualDuration>((ref) {
  final repository = ref.watch(taskExecutionSessionRepositoryProvider);
  return CalculateTaskActualDuration(repository);
});

