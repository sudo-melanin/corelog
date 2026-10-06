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

  Future<Either<Failure, List<HabitOccurrence>>> call({
    required DateTime from,
  }) async {
    final habitsResult = await _habitRepository.getHabits();

    return habitsResult.fold(
      Left.new,
      (habits) => _generateForHabits(habits, from),
    );
  }

  Future<Either<Failure, List<HabitOccurrence>>> _generateForHabits(
    List<Habit> habits,
    DateTime from,
  ) async {
    final createdOccurrences = <HabitOccurrence>[];

    final startDate = DateTime(from.year, from.month, from.day);
    final endDate = startDate.add(const Duration(days: 7));

    for (final habit in habits) {
      if (!habit.isActive) {
        continue;
      }

      var currentDate = startDate;

      while (currentDate.isBefore(endDate)) {
        if (!_isScheduledForWeekday(habit, currentDate)) {
          currentDate = currentDate.add(const Duration(days: 1));
          continue;
        }

        final existingResult =
            await _occurrenceRepository.getOccurrenceByHabitAndDate(
          habit.id,
          currentDate,
        );

        final existing = existingResult.fold(
          (failure) => returnLeftFailure(failure),
          (occurrence) => occurrence,
        );

        if (existing is _FailureResult) {
          return Left(existing.failure);
        }

        if ((existing as HabitOccurrence?) == null) {
          final occurrence = HabitOccurrence(
            id: 0,
            habitId: habit.id,
            scheduledDate: _scheduledDateFor(habit, currentDate),
            status: HabitOccurrenceStatus.pending,
            createdAt: DateTime.now(),
          );

          final createResult =
              await _occurrenceRepository.createOccurrence(occurrence);

          final created = createResult.fold(
            (failure) => returnLeftFailure(failure),
            (occurrence) => occurrence,
          );

          if (created is _FailureResult) {
            return Left(created.failure);
          }

          createdOccurrences.add(created as HabitOccurrence);
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return Right(createdOccurrences);
  }

  bool _isScheduledForWeekday(Habit habit, DateTime date) {
    final weekdayBit = 1 << (date.weekday - 1);
    return habit.weekdayMask & weekdayBit != 0;
  }

  DateTime _scheduledDateFor(Habit habit, DateTime date) {
    final targetTime = habit.targetTime;

    if (targetTime == null) {
      return date;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      targetTime.hour,
      targetTime.minute,
      targetTime.second,
      targetTime.millisecond,
      targetTime.microsecond,
    );
  }
}

class _FailureResult {
  const _FailureResult(this.failure);

  final Failure failure;
}

// ignore: library_private_types_in_public_api
_FailureResult returnLeftFailure(Failure failure) {
  return _FailureResult(failure);
}