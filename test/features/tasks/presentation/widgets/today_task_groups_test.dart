import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/widgets/today_task_groups.dart';

void main() {
  final currentTime = DateTime(2026, 9, 29, 12);

  Task createTask({
    int id = 1,
    String title = 'Test task',
    TaskStatus status = TaskStatus.pending,
    DateTime? plannedStart,
    DateTime? plannedEnd,
  }) {
    return Task(
      id: id,
      title: title,
      description: null,
      activityId: null,
      status: status,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      dueDate: null,
      completedAt: null,
      createdAt: currentTime,
      updatedAt: currentTime,
    );
  }

  group('TodayTaskGroups', () {
    test('places in-progress tasks in Now', () {
      final task = createTask(
        status: TaskStatus.inProgress,
        plannedStart: currentTime.subtract(const Duration(hours: 1)),
        plannedEnd: currentTime.subtract(const Duration(minutes: 30)),
      );

      final groups = TodayTaskGroups.fromTasks(
        [task],
        currentTime: currentTime,
      );

      expect(groups.now, contains(task));
      expect(groups.overdue, isEmpty);
      expect(groups.upNext, isEmpty);
      expect(groups.unscheduled, isEmpty);
    });

    test('places paused tasks in Now', () {
      final task = createTask(
        status: TaskStatus.paused,
        plannedStart: currentTime.subtract(const Duration(hours: 1)),
        plannedEnd: currentTime.subtract(const Duration(minutes: 30)),
      );

      final groups = TodayTaskGroups.fromTasks(
        [task],
        currentTime: currentTime,
      );

      expect(groups.now, contains(task));
      expect(groups.overdue, isEmpty);
      expect(groups.upNext, isEmpty);
      expect(groups.unscheduled, isEmpty);
    });

    test('places a currently scheduled pending task in Now', () {
      final task = createTask(
        plannedStart: currentTime.subtract(const Duration(minutes: 15)),
        plannedEnd: currentTime.add(const Duration(minutes: 45)),
      );

      final groups = TodayTaskGroups.fromTasks(
        [task],
        currentTime: currentTime,
      );

      expect(groups.now, contains(task));
      expect(groups.overdue, isEmpty);
      expect(groups.upNext, isEmpty);
      expect(groups.unscheduled, isEmpty);
    });

    test('places a past pending scheduled task in Overdue', () {
      final task = createTask(
        plannedStart: currentTime.subtract(const Duration(hours: 2)),
        plannedEnd: currentTime.subtract(const Duration(minutes: 15)),
      );

      final groups = TodayTaskGroups.fromTasks(
        [task],
        currentTime: currentTime,
      );

      expect(groups.now, isEmpty);
      expect(groups.overdue, contains(task));
      expect(groups.upNext, isEmpty);
      expect(groups.unscheduled, isEmpty);
    });

    test('places a future pending scheduled task in Up Next', () {
      final task = createTask(
        plannedStart: currentTime.add(const Duration(minutes: 30)),
        plannedEnd: currentTime.add(const Duration(hours: 1)),
      );

      final groups = TodayTaskGroups.fromTasks(
        [task],
        currentTime: currentTime,
      );

      expect(groups.now, isEmpty);
      expect(groups.overdue, isEmpty);
      expect(groups.upNext, contains(task));
      expect(groups.unscheduled, isEmpty);
    });

    test('places an unscheduled pending task in Unscheduled', () {
      final task = createTask();

      final groups = TodayTaskGroups.fromTasks(
        [task],
        currentTime: currentTime,
      );

      expect(groups.now, isEmpty);
      expect(groups.overdue, isEmpty);
      expect(groups.upNext, isEmpty);
      expect(groups.unscheduled, contains(task));
    });

    test('does not include completed or skipped tasks', () {
      final completedTask = createTask(
        id: 1,
        status: TaskStatus.completed,
        plannedStart: currentTime.subtract(const Duration(hours: 1)),
        plannedEnd: currentTime.add(const Duration(hours: 1)),
      );

      final skippedTask = createTask(
        id: 2,
        status: TaskStatus.skipped,
        plannedStart: currentTime.add(const Duration(minutes: 30)),
        plannedEnd: currentTime.add(const Duration(hours: 1)),
      );

      final groups = TodayTaskGroups.fromTasks(
        [completedTask, skippedTask],
        currentTime: currentTime,
      );

      expect(groups.now, isEmpty);
      expect(groups.overdue, isEmpty);
      expect(groups.upNext, isEmpty);
      expect(groups.unscheduled, isEmpty);
    });
  });
}