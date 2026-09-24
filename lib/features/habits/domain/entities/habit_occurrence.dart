import 'package:equatable/equatable.dart';

import 'habit_occurrence_status.dart';

class HabitOccurrence extends Equatable {
  const HabitOccurrence({
    required this.id,
    required this.habitId,
    required this.scheduledDate,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  final int id;
  final int habitId;
  final DateTime scheduledDate;
  final DateTime? completedAt;
  final HabitOccurrenceStatus status;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        habitId,
        scheduledDate,
        completedAt,
        status,
        createdAt,
      ];
}