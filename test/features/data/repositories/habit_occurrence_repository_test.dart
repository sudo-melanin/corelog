import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart' as db;
import 'package:corelog/features/habits/data/repositories/habit_occurrence_repository_impl.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';

void main() {
  late db.AppDatabase database;
  late HabitOccurrenceRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = HabitOccurrenceRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('getOccurrenceByHabitAndDate', () {
    test(
      'returns occurrence for the same calendar day',
      () async {
        final scheduledDate = DateTime(
          2026,
          9,
          25,
          7,
          30,
        );

        final occurrence = HabitOccurrence(
          id: 0,
          habitId: 1,
          scheduledDate: scheduledDate,
          status: HabitOccurrenceStatus.pending,
          createdAt: scheduledDate,
        );

        final createResult = await repository.createOccurrence(
          occurrence,
        );

        final createdOccurrence = createResult.getOrElse(
          (failure) => throw Exception(failure.message),
        );

        final result =
            await repository.getOccurrenceByHabitAndDate(
          createdOccurrence.habitId,
          DateTime(2026, 9, 25, 18, 45),
        );

        final foundOccurrence = result.getOrElse(
          (failure) => throw Exception(failure.message),
        );

        expect(foundOccurrence, isNotNull);
        expect(
          foundOccurrence!.id,
          createdOccurrence.id,
        );
        expect(
          foundOccurrence.scheduledDate,
          scheduledDate,
        );
      },
    );

    test(
      'returns null when no occurrence exists for the date',
      () async {
        final scheduledDate = DateTime(
          2026,
          9,
          25,
          7,
          30,
        );

        final occurrence = HabitOccurrence(
          id: 0,
          habitId: 1,
          scheduledDate: scheduledDate,
          status: HabitOccurrenceStatus.pending,
          createdAt: scheduledDate,
        );

        final createResult = await repository.createOccurrence(
          occurrence,
        );

        final createdOccurrence = createResult.getOrElse(
          (failure) => throw Exception(failure.message),
        );

        final result =
            await repository.getOccurrenceByHabitAndDate(
          createdOccurrence.habitId,
          DateTime(2026, 9, 26),
        );

        final foundOccurrence = result.getOrElse(
          (failure) => throw Exception(failure.message),
        );

        expect(foundOccurrence, isNull);
      },
    );

    test(
      'does not return an occurrence belonging to another habit',
      () async {
        final scheduledDate = DateTime(
          2026,
          9,
          25,
          7,
          30,
        );

        final occurrence = HabitOccurrence(
          id: 0,
          habitId: 1,
          scheduledDate: scheduledDate,
          status: HabitOccurrenceStatus.pending,
          createdAt: scheduledDate,
        );

        final createResult = await repository.createOccurrence(
          occurrence,
        );

        final createdOccurrence = createResult.getOrElse(
          (failure) => throw Exception(failure.message),
        );

        final result =
            await repository.getOccurrenceByHabitAndDate(
          2,
          DateTime(2026, 9, 25),
        );

        final foundOccurrence = result.getOrElse(
          (failure) => throw Exception(failure.message),
        );

        expect(foundOccurrence, isNull);
        expect(createdOccurrence.habitId, isNot(2));
      },
    );

  test(
    'getUpcomingOccurrences returns occurrences ordered by scheduled date',
    () async {
      final now = DateTime(2026, 9, 28, 8);
      final later = DateTime(2026, 9, 28, 12);
      final tomorrow = DateTime(2026, 9, 29, 9);

      await database.into(database.habitOccurrences).insert(
            db.HabitOccurrencesCompanion.insert(
              habitId: 1,
              scheduledDate: tomorrow,
              status: 'pending',
              createdAt: now,
            ),
          );

      await database.into(database.habitOccurrences).insert(
            db.HabitOccurrencesCompanion.insert(
              habitId: 1,
              scheduledDate: later,
              status: 'pending',
              createdAt: now,
            ),
          );

      final result = await repository.getUpcomingOccurrences(
        from: now,
        to: DateTime(2026, 9, 30),
      );

      expect(result.isRight(), isTrue);

      result.match(
        (_) => fail('Expected upcoming occurrences.'),
        (occurrences) {
          expect(occurrences, hasLength(2));
          expect(
            occurrences[0].scheduledDate,
            later,
          );
          expect(
            occurrences[1].scheduledDate,
            tomorrow,
          );
        },
      );
    },
  );
  });

  
}