import 'package:equatable/equatable.dart';

import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';

class TimeBlockTimelineItem extends Equatable {
  const TimeBlockTimelineItem({
    required this.timeBlock,
    required this.occurrence,
    required this.habit,
    this.task,
  });

  final TimeBlock timeBlock;
  final HabitOccurrence occurrence;
  final Habit habit;
  final Task? task;

  String get habitName => habit.name;

  String? get taskTitle => task?.title;

  @override
  List<Object?> get props => [
        timeBlock,
        occurrence,
        habit,
        task,
      ];
}