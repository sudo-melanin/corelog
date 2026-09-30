import 'package:corelog/features/tasks/domain/usecases/resume_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart' hide Task;
import 'package:corelog/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/usecases/usecases.dart';
import 'package:corelog/features/tasks/data/repositories/task_execution_session_repository_impl.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/history/data/repositories/activity_history_repository_impl.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TaskRepositoryImpl(database);
});

final completeTaskProvider = Provider<CompleteTask>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final sessionRepository =
      ref.watch(taskExecutionSessionRepositoryProvider);
  final historyRepository =
      ref.watch(activityHistoryRepositoryProvider);
  final calculateActualDuration =
      ref.watch(calculateTaskActualDurationProvider);

  return CompleteTask(
    taskRepository: taskRepository,
    sessionRepository: sessionRepository,
    historyRepository: historyRepository,
    calculateActualDuration: calculateActualDuration.call,
  );
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

final activityHistoryRepositoryProvider =
    Provider<ActivityHistoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ActivityHistoryRepositoryImpl(database);
});

final getTodayTasksProvider = Provider<GetTodayTasks>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return GetTodayTasks(repository);
});

final todayTasksProvider =
    FutureProvider.autoDispose<List<Task>>((ref) async {
  final getTodayTasks = ref.watch(getTodayTasksProvider);

  final result = await getTodayTasks(DateTime.now());

  return result.fold(
    (failure) => throw failure,
    (tasks) => tasks,
  );
});

