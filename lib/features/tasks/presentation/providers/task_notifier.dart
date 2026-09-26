import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/usecases.dart';

import 'task_providers.dart';

final taskNotifierProvider = AsyncNotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

class TaskNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  CompleteTask get _completeTask => ref.read(completeTaskProvider);

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

  Future<void> completeTask(Task task) async {
    await _runMutation(() => _completeTask(task));
  }

  Future<void> reopenTask(Task task) async {
    await _runMutation(() => _reopenTask(task));
  }

  Future<void> _runMutation<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    state = const AsyncLoading();

    try {
      final result = await action();

      await result.fold(
        (failure) async {
          state = AsyncError(failure, StackTrace.current);
        },
        (_) async {
          await refresh();
        },
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
