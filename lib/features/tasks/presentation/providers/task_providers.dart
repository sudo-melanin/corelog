import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/usecases.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TaskRepositoryImpl(database);
});

final completeTaskProvider = Provider<CompleteTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return CompleteTask(repository);
});

final reopenTaskProvider = Provider<ReopenTask>((ref) {
  final repository = ref.watch(taskRepositoryProvider);

  return ReopenTask(repository);
});