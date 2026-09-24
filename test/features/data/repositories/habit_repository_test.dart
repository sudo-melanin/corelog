import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/data/repositories/habit_occurrence_repository_impl.dart';
import 'package:corelog/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';

void main() {
  late db.AppDatabase database;
  late HabitRepositoryImpl habitRepository;
  late HabitOccurrenceRepositoryImpl habitOccurrenceRepository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    habitRepository = HabitRepositoryImpl(database);
    habitOccurrenceRepository = HabitOccurrenceRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('HabitRepositoryImpl', () {
    test('creates and reads a habit', () async {
      final now = DateTime(2026, 1, 1, 10);

      final habit = Habit(
        id: 0,
        name: 'Morning Reading',
        description: 'Read for 30 minutes',
        weekdayMask: 31,
        targetTime: DateTime(2026, 1, 1, 7),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final result = await habitRepository.createHabit(habit);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (created) {
          expect(created.id, isPositive);
          expect(created.name, 'Morning Reading');
          expect(created.description, 'Read for 30 minutes');
          expect(created.weekdayMask, 31);
          expect(created.targetTime, DateTime(2026, 1, 1, 7));
          expect(created.isActive, isTrue);
        },
      );

      final fetched = await habitRepository.getHabitById(1);

      expect(fetched.isRight(), isTrue);

      fetched.match(
        (failure) => fail(failure.message),
        (habit) {
          expect(habit, isNotNull);
          expect(habit!.name, 'Morning Reading');
        },
      );
    });

    test('gets all habits', () async {
      final now = DateTime(2026, 1, 1, 10);

      await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Evening Review',
          weekdayMask: 62,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final result = await habitRepository.getHabits();

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (habits) {
          expect(habits, hasLength(2));
          expect(
            habits.map((habit) => habit.name),
            containsAll([
              'Morning Reading',
              'Evening Review',
            ]),
          );
        },
      );
    });

    test('updates a habit', () async {
      final now = DateTime(2026, 1, 1, 10);

      final createdResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          description: 'Read for 30 minutes',
          weekdayMask: 31,
          targetTime: DateTime(2026, 1, 1, 7),
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit created;

      createdResult.match(
        (failure) => fail(failure.message),
        (habit) => created = habit,
      );

      final updatedHabit = Habit(
        id: created.id,
        name: 'Morning Deep Reading',
        description: 'Read for 60 minutes',
        weekdayMask: 63,
        targetTime: DateTime(2026, 1, 1, 6),
        isActive: false,
        createdAt: created.createdAt,
        updatedAt: DateTime(2026, 1, 2, 10),
      );

      final result = await habitRepository.updateHabit(updatedHabit);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (updated) {
          expect(updated.id, created.id);
          expect(updated.name, 'Morning Deep Reading');
          expect(updated.description, 'Read for 60 minutes');
          expect(updated.weekdayMask, 63);
          expect(updated.targetTime, DateTime(2026, 1, 1, 6));
          expect(updated.isActive, isFalse);
          expect(updated.updatedAt, DateTime(2026, 1, 2, 10));
        },
      );
    });

    test('deletes a habit', () async {
      final now = DateTime(2026, 1, 1, 10);

      final createdResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit created;

      createdResult.match(
        (failure) => fail(failure.message),
        (habit) => created = habit,
      );

      final deleteResult = await habitRepository.deleteHabit(created.id);

      expect(deleteResult.isRight(), isTrue);

      final fetchResult =
          await habitRepository.getHabitById(created.id);

      expect(fetchResult.isRight(), isTrue);

      fetchResult.match(
        (failure) => fail(failure.message),
        (habit) => expect(habit, isNull),
      );
    });

    test('returns failure when updating a missing habit', () async {
      final now = DateTime(2026, 1, 1, 10);

      final result = await habitRepository.updateHabit(
        Habit(
          id: 999,
          name: 'Missing Habit',
          weekdayMask: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Habit not found.');
        },
        (_) => fail('Expected a failure.'),
      );
    });

    test('returns failure when deleting a missing habit', () async {
      final result = await habitRepository.deleteHabit(999);

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Habit not found.');
        },
        (_) => fail('Expected a failure.'),
      );
    });
  });

  group('HabitOccurrenceRepositoryImpl', () {
    test('creates and reads a habit occurrence', () async {
      final now = DateTime(2026, 1, 1, 10);

      final habitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit habit;

      habitResult.match(
        (failure) => fail(failure.message),
        (created) => habit = created,
      );

      final result =
          await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: habit.id,
          scheduledDate: DateTime(2026, 1, 2),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (created) {
          expect(created.id, isPositive);
          expect(created.habitId, habit.id);
          expect(created.scheduledDate, DateTime(2026, 1, 2));
          expect(created.status, HabitOccurrenceStatus.pending);
          expect(created.completedAt, isNull);
        },
      );
    });

    test('gets all occurrences', () async {
      final now = DateTime(2026, 1, 1, 10);

      final habitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit habit;

      habitResult.match(
        (failure) => fail(failure.message),
        (created) => habit = created,
      );

      await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: habit.id,
          scheduledDate: DateTime(2026, 1, 1),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: habit.id,
          scheduledDate: DateTime(2026, 1, 2),
          status: HabitOccurrenceStatus.completed,
          completedAt: DateTime(2026, 1, 2, 8),
          createdAt: now,
        ),
      );

      final result = await habitOccurrenceRepository.getOccurrences();

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (occurrences) => expect(occurrences, hasLength(2)),
      );
    });

    test('gets occurrences by habit', () async {
      final now = DateTime(2026, 1, 1, 10);

      final firstHabitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final secondHabitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Evening Review',
          weekdayMask: 62,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit firstHabit;
      late Habit secondHabit;

      firstHabitResult.match(
        (failure) => fail(failure.message),
        (habit) => firstHabit = habit,
      );

      secondHabitResult.match(
        (failure) => fail(failure.message),
        (habit) => secondHabit = habit,
      );

      await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: firstHabit.id,
          scheduledDate: DateTime(2026, 1, 1),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: firstHabit.id,
          scheduledDate: DateTime(2026, 1, 2),
          status: HabitOccurrenceStatus.completed,
          createdAt: now,
        ),
      );

      await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: secondHabit.id,
          scheduledDate: DateTime(2026, 1, 1),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      final result = await habitOccurrenceRepository
          .getOccurrencesByHabit(firstHabit.id);

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (occurrences) {
          expect(occurrences, hasLength(2));
          expect(
            occurrences.every(
              (occurrence) => occurrence.habitId == firstHabit.id,
            ),
            isTrue,
          );
        },
      );
    });

    test('updates a habit occurrence', () async {
      final now = DateTime(2026, 1, 1, 10);

      final habitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit habit;

      habitResult.match(
        (failure) => fail(failure.message),
        (created) => habit = created,
      );

      final createdResult =
          await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: habit.id,
          scheduledDate: DateTime(2026, 1, 2),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      late HabitOccurrence created;

      createdResult.match(
        (failure) => fail(failure.message),
        (occurrence) => created = occurrence,
      );

      final completedAt = DateTime(2026, 1, 2, 8);

      final result =
          await habitOccurrenceRepository.updateOccurrence(
        HabitOccurrence(
          id: created.id,
          habitId: created.habitId,
          scheduledDate: created.scheduledDate,
          status: HabitOccurrenceStatus.completed,
          completedAt: completedAt,
          createdAt: created.createdAt,
        ),
      );

      expect(result.isRight(), isTrue);

      result.match(
        (failure) => fail(failure.message),
        (updated) {
          expect(updated.id, created.id);
          expect(updated.status, HabitOccurrenceStatus.completed);
          expect(updated.completedAt, completedAt);
        },
      );
    });

    test('deletes a habit occurrence', () async {
      final now = DateTime(2026, 1, 1, 10);

      final habitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit habit;

      habitResult.match(
        (failure) => fail(failure.message),
        (created) => habit = created,
      );

      final occurrenceResult =
          await habitOccurrenceRepository.createOccurrence(
        HabitOccurrence(
          id: 0,
          habitId: habit.id,
          scheduledDate: DateTime(2026, 1, 2),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      late HabitOccurrence occurrence;

      occurrenceResult.match(
        (failure) => fail(failure.message),
        (created) => occurrence = created,
      );

      final deleteResult =
          await habitOccurrenceRepository.deleteOccurrence(
        occurrence.id,
      );

      expect(deleteResult.isRight(), isTrue);

      final fetchResult =
          await habitOccurrenceRepository.getOccurrenceById(
        occurrence.id,
      );

      expect(fetchResult.isRight(), isTrue);

      fetchResult.match(
        (failure) => fail(failure.message),
        (fetched) => expect(fetched, isNull),
      );
    });

    test('returns failure when updating a missing occurrence', () async {
      final now = DateTime(2026, 1, 1, 10);

      final habitResult = await habitRepository.createHabit(
        Habit(
          id: 0,
          name: 'Morning Reading',
          weekdayMask: 31,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      late Habit habit;

      habitResult.match(
        (failure) => fail(failure.message),
        (created) => habit = created,
      );

      final result =
          await habitOccurrenceRepository.updateOccurrence(
        HabitOccurrence(
          id: 999,
          habitId: habit.id,
          scheduledDate: DateTime(2026, 1, 2),
          status: HabitOccurrenceStatus.pending,
          createdAt: now,
        ),
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Habit occurrence not found.');
        },
        (_) => fail('Expected a failure.'),
      );
    });

    test('returns failure when deleting a missing occurrence', () async {
      final result =
          await habitOccurrenceRepository.deleteOccurrence(999);

      expect(result.isLeft(), isTrue);

      result.match(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Habit occurrence not found.');
        },
        (_) => fail('Expected a failure.'),
      );
    });
  });
}