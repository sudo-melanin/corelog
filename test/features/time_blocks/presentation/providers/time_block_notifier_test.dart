import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';
import 'package:corelog/features/habits/presentation/providers/providers.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';
import 'package:corelog/features/time_blocks/presentation/providers/providers.dart';

class MockTimeBlockRepository extends Mock
    implements TimeBlockRepository {}

class MockHabitOccurrenceRepository extends Mock
    implements HabitOccurrenceRepository {}

class MockHabitRepository extends Mock
    implements HabitRepository {}

class MockTaskRepository extends Mock
    implements TaskRepository {}

void main() {
  late MockTimeBlockRepository timeBlockRepository;
  late MockHabitOccurrenceRepository habitOccurrenceRepository;
  late MockHabitRepository habitRepository;
  late MockTaskRepository taskRepository;

  setUp(() {
    timeBlockRepository = MockTimeBlockRepository();
    habitOccurrenceRepository = MockHabitOccurrenceRepository();
    habitRepository = MockHabitRepository();
    taskRepository = MockTaskRepository();
  });

  test(
    'loadTimeline composes time blocks with their occurrence, habit, and task',
    () async {
      final date = DateTime(2026, 9, 25);

      final habit = Habit(
        id: 1,
        name: 'Flutter Learning',
        description: 'Study Flutter',
        weekdayMask: 127,
        targetTime: DateTime(2026, 9, 25, 9),
        targetDuration: const Duration(hours: 1),
        isActive: true,
        createdAt: DateTime(2026, 9, 25, 8),
        updatedAt: DateTime(2026, 9, 25, 8),
      );

      final occurrence = HabitOccurrence(
        id: 2,
        habitId: habit.id,
        scheduledDate: date,
        completedAt: null,
        status: HabitOccurrenceStatus.pending,
        createdAt: DateTime(2026, 9, 25, 8),
      );

      final task = Task(
        id: 10,
        projectId: null,
        title: 'Build timeline',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 9, 25, 8),
        updatedAt: DateTime(2026, 9, 25, 8),
      );

      final timeBlock = TimeBlock(
        id: 100,
        habitOccurrenceId: occurrence.id,
        taskId: task.id,
        plannedStart: DateTime(2026, 9, 25, 9),
        plannedEnd: DateTime(2026, 9, 25, 10),
        status: TimeBlockStatus.planned,
        createdAt: DateTime(2026, 9, 25, 8),
        updatedAt: DateTime(2026, 9, 25, 8),
      );

      when(
        () => timeBlockRepository.getTimeBlocks(),
      ).thenAnswer(
        (_) async => const Right([]),
      );

      when(
        () => timeBlockRepository.getTimeBlocksByDate(date),
      ).thenAnswer(
        (_) async => Right([timeBlock]),
      );

      when(
        () => habitOccurrenceRepository.getOccurrenceById(
          occurrence.id,
        ),
      ).thenAnswer(
        (_) async => Right(occurrence),
      );

      when(
        () => habitRepository.getHabitById(habit.id),
      ).thenAnswer(
        (_) async => Right(habit),
      );

      when(
        () => taskRepository.getTaskById(task.id),
      ).thenAnswer(
        (_) async => Right(task),
      );

      final container = ProviderContainer(
        overrides: [
          timeBlockRepositoryProvider.overrideWithValue(
            timeBlockRepository,
          ),
          habitOccurrenceRepositoryProvider.overrideWithValue(
            habitOccurrenceRepository,
          ),
          habitRepositoryProvider.overrideWithValue(
            habitRepository,
          ),
          taskRepositoryProvider.overrideWithValue(
            taskRepository,
          ),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(
        timeBlockNotifierProvider.notifier,
      );

      final items = await notifier.loadTimeline(date);

      expect(items, hasLength(1));
      expect(items.first.timeBlock, equals(timeBlock));
      expect(items.first.occurrence, equals(occurrence));
      expect(items.first.habit, equals(habit));
      expect(items.first.habitName, equals('Flutter Learning'));
      expect(items.first.task, equals(task));
      expect(items.first.taskTitle, equals('Build timeline'));

      verify(
        () => timeBlockRepository.getTimeBlocksByDate(date),
      ).called(1);

      verify(
        () => habitOccurrenceRepository.getOccurrenceById(
          occurrence.id,
        ),
      ).called(1);

      verify(
        () => habitRepository.getHabitById(habit.id),
      ).called(1);

      verify(
        () => taskRepository.getTaskById(task.id),
      ).called(1);
    },
  );

  test(
    'loadTimeline supports time blocks without a task',
    () async {
      final date = DateTime(2026, 9, 25);

      final habit = Habit(
        id: 1,
        name: 'Flutter Learning',
        weekdayMask: 127,
        isActive: true,
        createdAt: DateTime(2026, 9, 25, 8),
        updatedAt: DateTime(2026, 9, 25, 8),
      );

      final occurrence = HabitOccurrence(
        id: 2,
        habitId: habit.id,
        scheduledDate: date,
        status: HabitOccurrenceStatus.pending,
        createdAt: DateTime(2026, 9, 25, 8),
      );

      final timeBlock = TimeBlock(
        id: 100,
        habitOccurrenceId: occurrence.id,
        plannedStart: DateTime(2026, 9, 25, 9),
        plannedEnd: DateTime(2026, 9, 25, 10),
        status: TimeBlockStatus.planned,
        createdAt: DateTime(2026, 9, 25, 8),
        updatedAt: DateTime(2026, 9, 25, 8),
      );

      when(
        () => timeBlockRepository.getTimeBlocks(),
      ).thenAnswer(
        (_) async => const Right([]),
      );

      when(
        () => timeBlockRepository.getTimeBlocksByDate(date),
      ).thenAnswer(
        (_) async => Right([timeBlock]),
      );

      when(
        () => habitOccurrenceRepository.getOccurrenceById(
          occurrence.id,
        ),
      ).thenAnswer(
        (_) async => Right(occurrence),
      );

      when(
        () => habitRepository.getHabitById(habit.id),
      ).thenAnswer(
        (_) async => Right(habit),
      );

      final container = ProviderContainer(
        overrides: [
          timeBlockRepositoryProvider.overrideWithValue(
            timeBlockRepository,
          ),
          habitOccurrenceRepositoryProvider.overrideWithValue(
            habitOccurrenceRepository,
          ),
          habitRepositoryProvider.overrideWithValue(
            habitRepository,
          ),
          taskRepositoryProvider.overrideWithValue(
            taskRepository,
          ),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(
        timeBlockNotifierProvider.notifier,
      );

      final items = await notifier.loadTimeline(date);

      expect(items, hasLength(1));
      expect(items.first.habit, equals(habit));
      expect(items.first.habitName, equals('Flutter Learning'));
      expect(items.first.task, isNull);

      verifyNever(
        () => taskRepository.getTaskById(any()),
      );
    },
  );

  test(
    'loadTimeline skips time blocks whose habit occurrence is missing',
    () async {
      final date = DateTime(2026, 9, 25);

      final timeBlock = TimeBlock(
        id: 100,
        habitOccurrenceId: 999,
        plannedStart: DateTime(2026, 9, 25, 9),
        plannedEnd: DateTime(2026, 9, 25, 10),
        status: TimeBlockStatus.planned,
        createdAt: DateTime(2026, 9, 25, 8),
        updatedAt: DateTime(2026, 9, 25, 8),
      );

      when(
        () => timeBlockRepository.getTimeBlocks(),
      ).thenAnswer(
        (_) async => const Right([]),
      );

      when(
        () => timeBlockRepository.getTimeBlocksByDate(date),
      ).thenAnswer(
        (_) async => Right([timeBlock]),
      );

      when(
        () => habitOccurrenceRepository.getOccurrenceById(999),
      ).thenAnswer(
        (_) async => const Right(null),
      );

      final container = ProviderContainer(
        overrides: [
          timeBlockRepositoryProvider.overrideWithValue(
            timeBlockRepository,
          ),
          habitOccurrenceRepositoryProvider.overrideWithValue(
            habitOccurrenceRepository,
          ),
          habitRepositoryProvider.overrideWithValue(
            habitRepository,
          ),
          taskRepositoryProvider.overrideWithValue(
            taskRepository,
          ),
        ],
      );

      addTearDown(container.dispose);

      final notifier = container.read(
        timeBlockNotifierProvider.notifier,
      );

      final items = await notifier.loadTimeline(date);

      expect(items, isEmpty);

      verifyNever(
        () => habitRepository.getHabitById(any()),
      );

      verifyNever(
        () => taskRepository.getTaskById(any()),
      );
    },
  );
}