import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';

enum HabitOccurrenceDisplayStatus { upcoming, due, missed, completed, skipped }

HabitOccurrenceDisplayStatus getHabitOccurrenceDisplayStatus(
  HabitOccurrence occurrence, {
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();

  switch (occurrence.status) {
    case HabitOccurrenceStatus.completed:
      return HabitOccurrenceDisplayStatus.completed;

    case HabitOccurrenceStatus.skipped:
      return HabitOccurrenceDisplayStatus.skipped;

    case HabitOccurrenceStatus.pending:
      final scheduledDate = occurrence.scheduledDate;

      final scheduledDay = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      final currentDay = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
      );

      if (scheduledDay.isBefore(currentDay)) {
        return HabitOccurrenceDisplayStatus.missed;
      }

      if (scheduledDay.isAfter(currentDay)) {
        return HabitOccurrenceDisplayStatus.upcoming;
      }

      if (scheduledDate.isAfter(currentTime)) {
        return HabitOccurrenceDisplayStatus.upcoming;
      }

      return HabitOccurrenceDisplayStatus.due;
  }
}
