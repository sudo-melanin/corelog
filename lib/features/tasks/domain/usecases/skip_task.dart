import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class SkipTask {
  const SkipTask({
    required this.taskRepository,
    required this.historyRepository,
  });

  final TaskRepository taskRepository;
  final ActivityHistoryRepository historyRepository;

  Future<Either<Failure, Task>> call({
    required Task task,
    required TaskSkipReason reason,
    String? note,
  }) async {
    if (task.status != TaskStatus.pending) {
      return const Left(
        ValidationFailure(
          'Only pending tasks can be skipped.',
        ),
      );
    }

    final now = DateTime.now();

    final skippedTask = Task(
      id: task.id,
      activityId: task.activityId,
      title: task.title,
      description: task.description,
      status: TaskStatus.skipped,
      dueDate: task.dueDate,
      plannedStart: task.plannedStart,
      plannedEnd: task.plannedEnd,
      completedAt: task.completedAt,
      skippedAt: now,
      skipReason: reason,
      skipNote: note,
      createdAt: task.createdAt,
      updatedAt: now,
    );

    final taskResult = await taskRepository.updateTask(
      skippedTask,
    );

    if (taskResult.isLeft()) {
      return taskResult;
    }

    final updatedTask = taskResult.getOrElse(
      (_) => throw StateError('Expected an updated task.'),
    );

    final history = ActivityHistory(
      id: 0,
      taskId: updatedTask.id,
      activityId: updatedTask.activityId,
      taskTitle: updatedTask.title,
      plannedStart: updatedTask.plannedStart,
      plannedEnd: updatedTask.plannedEnd,
      outcome: HistoryOutcome.skipped,
      occurredAt: updatedTask.skippedAt!,
      actualDuration: Duration.zero,
      skipReason: updatedTask.skipReason,
      skipNote: updatedTask.skipNote,
    );

    final historyResult = await historyRepository.createHistory(
      history,
    );

    return historyResult.map((_) => updatedTask);
  }
}