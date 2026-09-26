import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';

import 'habit_providers.dart';

final habitNotifierProvider = AsyncNotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);

class HabitNotifier extends AsyncNotifier<List<Habit>> {
  HabitRepository get _repository => ref.read(habitRepositoryProvider);

  @override
  Future<List<Habit>> build() async {
    final result = await _repository.getHabits();

    return result.fold((failure) => throw failure, (habits) => habits);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> createHabit(Habit habit) async {
    await _runMutation(() => _repository.createHabit(habit));
  }

  Future<void> updateHabit(Habit habit) async {
    await _runMutation(() => _repository.updateHabit(habit));
  }

  Future<void> deleteHabit(int id) async {
    await _runMutation(() => _repository.deleteHabit(id));
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
