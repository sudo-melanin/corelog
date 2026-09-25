import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/usecases/usecases.dart';

import 'habit_providers.dart';

final habitOccurrenceNotifierProvider =
    AsyncNotifierProvider<HabitOccurrenceNotifier, List<HabitOccurrence>>(
  HabitOccurrenceNotifier.new,
);

class HabitOccurrenceNotifier extends AsyncNotifier<List<HabitOccurrence>> {
  HabitOccurrenceRepository get _repository =>
      ref.read(habitOccurrenceRepositoryProvider);

  CompleteHabitOccurrence get _completeOccurrence =>
      ref.read(completeHabitOccurrenceProvider);

  SkipHabitOccurrence get _skipOccurrence =>
      ref.read(skipHabitOccurrenceProvider);

  @override
  Future<List<HabitOccurrence>> build() async {
    final result = await _repository.getOccurrences();

    return result.fold(
      (failure) => throw failure,
      (occurrences) => occurrences,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> createOccurrence(
    HabitOccurrence occurrence,
  ) async {
    await _runMutation(
      () => _repository.createOccurrence(occurrence),
    );
  }

  Future<void> updateOccurrence(
    HabitOccurrence occurrence,
  ) async {
    await _runMutation(
      () => _repository.updateOccurrence(occurrence),
    );
  }

  Future<void> deleteOccurrence(int id) async {
    await _runMutation(
      () => _repository.deleteOccurrence(id),
    );
  }

  Future<void> completeOccurrence(
    HabitOccurrence occurrence,
  ) async {
    await _runMutation(
      () => _completeOccurrence(occurrence),
    );
  }

  Future<void> skipOccurrence(
    HabitOccurrence occurrence,
  ) async {
    await _runMutation(
      () => _skipOccurrence(occurrence),
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