import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Task;

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';
import 'package:corelog/features/time_blocks/domain/usecases/usecases.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';
import 'package:corelog/features/habits/presentation/providers/providers.dart';
import '../utils/utils.dart';

import 'time_block_providers.dart';

final timeBlockNotifierProvider =
    AsyncNotifierProvider<TimeBlockNotifier, List<TimeBlock>>(
      TimeBlockNotifier.new,
    );

class TimeBlockNotifier extends AsyncNotifier<List<TimeBlock>> {
  TimeBlockRepository get _repository => ref.read(timeBlockRepositoryProvider);

  TaskRepository get _taskRepository => ref.read(taskRepositoryProvider);

  StartTimeBlock get _startTimeBlock => ref.read(startTimeBlockProvider);

  CompleteTimeBlock get _completeTimeBlock =>
      ref.read(completeTimeBlockProvider);

  SkipTimeBlock get _skipTimeBlock => ref.read(skipTimeBlockProvider);

  HabitOccurrenceRepository get _habitOccurrenceRepository =>
    ref.read(habitOccurrenceRepositoryProvider);

HabitRepository get _habitRepository =>
    ref.read(habitRepositoryProvider);

  @override
  Future<List<TimeBlock>> build() async {
    final result = await _repository.getTimeBlocks();

    return result.fold((failure) => throw failure, (timeBlocks) => timeBlocks);
  }

  Future<List<TimeBlockTimelineItem>> loadTimeline(
  DateTime date,
) async {
  final result = await _repository.getTimeBlocksByDate(date);

  return result.fold(
    (failure) => throw failure,
    (timeBlocks) async {
      final items = <TimeBlockTimelineItem>[];

      for (final timeBlock in timeBlocks) {
        final occurrenceResult =
            await _habitOccurrenceRepository.getOccurrenceById(
          timeBlock.habitOccurrenceId,
        );

        final occurrence = occurrenceResult.fold(
          (failure) => throw failure,
          (occurrence) => occurrence,
        );

        if (occurrence == null) {
          continue;
        }

        final habitResult = await _habitRepository.getHabitById(
          occurrence.habitId,
        );

        final habit = habitResult.fold(
          (failure) => throw failure,
          (habit) => habit,
        );

        if (habit == null) {
          continue;
        }

        Task? task;

        if (timeBlock.taskId != null) {
          final taskResult = await _taskRepository.getTaskById(
            timeBlock.taskId!,
          );

          task = taskResult.fold(
            (failure) => throw failure,
            (task) => task,
          );
        }

        items.add(
          TimeBlockTimelineItem(
            timeBlock: timeBlock,
            occurrence: occurrence,
            habit: habit,
            task: task,
          ),
        );
      }

      return items;
    },
  );
}

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> createTimeBlock(TimeBlock timeBlock) async {
    await _runMutation(() => _repository.createTimeBlock(timeBlock));
  }

  Future<void> updateTimeBlock(TimeBlock timeBlock) async {
    await _runMutation(() => _repository.updateTimeBlock(timeBlock));
  }

  Future<void> deleteTimeBlock(int id) async {
    await _runMutation(() => _repository.deleteTimeBlock(id));
  }

  Future<void> startTimeBlock(TimeBlock timeBlock) async {
    await _runMutation(() => _startTimeBlock(timeBlock));
  }

  Future<void> completeTimeBlock(TimeBlock timeBlock) async {
    await _runMutation(() => _completeTimeBlock(timeBlock));
  }

  Future<void> skipTimeBlock(TimeBlock timeBlock) async {
    await _runMutation(() => _skipTimeBlock(timeBlock));
  }

  Future<void> _runMutation<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    state = const AsyncLoading();

    final result = await action();

    await result.fold(
      (failure) async {
        state = AsyncError(failure.message, StackTrace.current);
      },
      (_) async {
        await refresh();
      },
    );
  }
}
