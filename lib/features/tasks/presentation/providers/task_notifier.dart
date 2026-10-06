import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/usecases.dart';
import 'task_providers.dart';

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

class TaskNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  StartTask get _startTask => ref.read(startTaskProvider);

  PauseTask get _pauseTask => ref.read(pauseTaskProvider);

  ResumeTask get _resumeTask => ref.read(resumeTaskProvider);

  CompleteTask get _completeTask => ref.read(completeTaskProvider);

  SkipTask get _skipTask => ref.read(skipTaskProvider);

  ReopenTask get _reopenTask => ref.read(reopenTaskProvider);

  @override
  Future<List<Task>> build() async {
    final result = await _repository.getTasks();

    return result.fold((failure) => throw failure, (tasks) => tasks);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> createTask(Task task) async {
    await _runMutation(() => _repository.createTask(task));
  }

  Future<void> updateTask(Task task) async {
    await _runMutation(() => _repository.updateTask(task));
  }

  Future<void> deleteTask(int id) async {
    await _runMutation(() => _repository.deleteTask(id));
  }

  Future<bool> startTask(Task task) {
    return _runMutation(() => _startTask(task));
  }

  Future<bool> pauseTask(Task task) {
    return _runMutation(() => _pauseTask(task));
  }

  Future<bool> resumeTask(Task task) {
    return _runMutation(() => _resumeTask(task));
  }

  Future<bool> completeTask(Task task) {
    return _runMutation(() => _completeTask(task));
  }

  Future<bool> skipTask({
    required Task task,
    required TaskSkipReason reason,
    String? note,
  }) {
    return _runMutation(
      () => _skipTask(
        task: task,
        reason: reason,
        note: note,
      ),
    );
  }

  Future<bool> reopenTask(Task task) {
    return _runMutation(() => _reopenTask(task));
  }

  Future<bool> _runMutation<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    state = const AsyncLoading();

    try {
      final result = await action();

      return result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
          return false;
        },
        (_) async {
          await refresh();
          return true;
        },
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}