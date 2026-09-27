import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';
import 'package:corelog/features/time_blocks/presentation/utils/time_block_timeline_item.dart';

void main() {
  final habit = Habit(
    id: 1,
    projectId: null,
    name: 'Flutter Learning',
    description: 'Study Flutter',
    weekdayMask: 127,
    targetTime: DateTime(2026, 1, 1, 9),
    targetDuration: const Duration(hours: 1),
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final occurrence = HabitOccurrence(
    id: 1,
    habitId: habit.id,
    scheduledDate: DateTime(2026, 1, 1),
    completedAt: null,
    status: HabitOccurrenceStatus.pending,
    createdAt: DateTime(2026, 1, 1),
  );

  final task = Task(
    id: 1,
    projectId: null,
    title: 'Build CoreLog timeline',
    description: null,
    status: TaskStatus.pending,
    dueDate: null,
    completedAt: null,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final timeBlock = TimeBlock(
    id: 1,
    habitOccurrenceId: occurrence.id,
    taskId: task.id,
    plannedStart: DateTime(2026, 1, 1, 9),
    plannedEnd: DateTime(2026, 1, 1, 10),
    actualStart: null,
    actualEnd: null,
    status: TimeBlockStatus.planned,
    createdAt: DateTime(2026, 1, 1, 9),
    updatedAt: DateTime(2026, 1, 1, 9),
  );

  test('exposes habit name and optional task title', () {
    final item = TimeBlockTimelineItem(
      timeBlock: timeBlock,
      occurrence: occurrence,
      habit: habit,
      task: task,
    );

    expect(item.habitName, 'Flutter Learning');
    expect(item.taskTitle, 'Build CoreLog timeline');
  });

  test('allows a timeline item without a task', () {
    final item = TimeBlockTimelineItem(
      timeBlock: timeBlock,
      occurrence: occurrence,
      habit: habit,
    );

    expect(item.habitName, 'Flutter Learning');
    expect(item.taskTitle, isNull);
  });

  test('contains the original timeline entities', () {
    final item = TimeBlockTimelineItem(
      timeBlock: timeBlock,
      occurrence: occurrence,
      habit: habit,
      task: task,
    );

    expect(item.timeBlock, timeBlock);
    expect(item.occurrence, occurrence);
    expect(item.habit, habit);
    expect(item.task, task);
  });
}