import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';

class UpcomingHabitOccurrence {
  const UpcomingHabitOccurrence({
    required this.occurrence,
    required this.habit,
  });

  final HabitOccurrence occurrence;
  final Habit habit;
}