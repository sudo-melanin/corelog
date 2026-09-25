import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';
import 'package:corelog/features/time_blocks/domain/usecases/usecases.dart';

import 'time_block_providers.dart';

final timeBlockNotifierProvider =
    AsyncNotifierProvider<TimeBlockNotifier, List<TimeBlock>>(
  TimeBlockNotifier.new,
);

class TimeBlockNotifier extends AsyncNotifier<List<TimeBlock>> {
  TimeBlockRepository get _repository =>
      ref.read(timeBlockRepositoryProvider);

  StartTimeBlock get _startTimeBlock =>
      ref.read(startTimeBlockProvider);

  CompleteTimeBlock get _completeTimeBlock =>
      ref.read(completeTimeBlockProvider);

  SkipTimeBlock get _skipTimeBlock =>
      ref.read(skipTimeBlockProvider);

  @override
  Future<List<TimeBlock>> build() async {
    final result = await _repository.getTimeBlocks();

    return result.fold(
      (failure) => throw failure,
      (timeBlocks) => timeBlocks,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> createTimeBlock(
    TimeBlock timeBlock,
  ) async {
    await _runMutation(
      () => _repository.createTimeBlock(timeBlock),
    );
  }

  Future<void> updateTimeBlock(
    TimeBlock timeBlock,
  ) async {
    await _runMutation(
      () => _repository.updateTimeBlock(timeBlock),
    );
  }

  Future<void> deleteTimeBlock(int id) async {
    await _runMutation(
      () => _repository.deleteTimeBlock(id),
    );
  }

  Future<void> startTimeBlock(
    TimeBlock timeBlock,
  ) async {
    await _runMutation(
      () => _startTimeBlock(timeBlock),
    );
  }

  Future<void> completeTimeBlock(
    TimeBlock timeBlock,
  ) async {
    await _runMutation(
      () => _completeTimeBlock(timeBlock),
    );
  }

  Future<void> skipTimeBlock(
    TimeBlock timeBlock,
  ) async {
    await _runMutation(
      () => _skipTimeBlock(timeBlock),
    );
  }

  Future<void> _runMutation<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    state = const AsyncLoading();

    final result = await action();

    await result.fold(
      (failure) async {
        state = AsyncError(
          failure.message,
          StackTrace.current,
        );
      },
      (_) async {
        await refresh();
      },
    );
  }
}