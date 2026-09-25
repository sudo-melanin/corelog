import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';

class GenerateHabitOccurrences {
  const GenerateHabitOccurrences({
    required this._habitRepository,
    required this._occurrenceRepository,
  });

  final HabitRepository _habitRepository;
  final HabitOccurrenceRepository _occurrenceRepository;

  Future<Either<Failure, Unit>> call({
    DateTime? from,
  }) async {
    final habitsResult = await _habitRepository.getHabits();

    return habitsResult.fold(
      Left.new,
      (habits) async {
        final startDate = _startOfDay(from ?? DateTime.now());

        for (final habit in habits) {
          if (!habit.isActive) {
            continue;
          }

          for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
            final date = startDate.add(
              Duration(days: dayOffset),
            );

            if (!_isScheduledForDate(habit, date)) {
              continue;
            }

            final result = await _ensureOccurrence(
              habit,
              date,
            );

            if (result.isLeft()) {
              return result;
            }
          }
        }

        return const Right(unit);
      },
    );
  }

  Future<Either<Failure, Unit>> _ensureOccurrence(
    Habit habit,
    DateTime date,
  ) async {
    final existingResult =
        await _occurrenceRepository.getOccurrenceByHabitAndDate(
      habit.id,
      date,
    );

    return existingResult.fold(
      Left.new,
      (existing) async {
        if (existing != null) {
          return const Right(unit);
        }

        final occurrence = HabitOccurrence(
          id: 0,
          habitId: habit.id,
          scheduledDate: _scheduledDate(
            date,
            habit.targetTime,
          ),
          status: HabitOccurrenceStatus.pending,
          createdAt: DateTime.now(),
        );

        final createResult =
            await _occurrenceRepository.createOccurrence(
          occurrence,
        );

        return createResult.fold(
          (failure) => Left(failure),
          (_) => const Right(unit),
        );
      },
    );
  }

  bool _isScheduledForDate(
    Habit habit,
    DateTime date,
  ) {
    final bit = 1 << (date.weekday - 1);

    return (habit.weekdayMask & bit) != 0;
  }

  DateTime _scheduledDate(
    DateTime date,
    DateTime? targetTime,
  ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      targetTime?.hour ?? 0,
      targetTime?.minute ?? 0,
    );
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }
}