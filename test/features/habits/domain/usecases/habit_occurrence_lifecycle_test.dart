import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/usecases/complete_habit_occurrence.dart';
import 'package:corelog/features/habits/domain/usecases/skip_habit_occurrence.dart';

class MockHabitOccurrenceRepository extends Mock
    implements HabitOccurrenceRepository {}

void main() {
  late MockHabitOccurrenceRepository repository;
  late CompleteHabitOccurrence completeOccurrence;
  late SkipHabitOccurrence skipOccurrence;

  setUpAll(() {
  registerFallbackValue(
    HabitOccurrence(
      id: 0,
      habitId: 0,
      scheduledDate: DateTime(2026),
      status: HabitOccurrenceStatus.pending,
      createdAt: DateTime(2026),
    ),
  );
});

  setUp(() {
    repository = MockHabitOccurrenceRepository();
    completeOccurrence = CompleteHabitOccurrence(repository);
    skipOccurrence = SkipHabitOccurrence(repository);
  });

  final createdAt = DateTime(2026, 1, 1, 9);
  final scheduledDate = DateTime(2026, 1, 2);

  HabitOccurrence buildOccurrence({
    HabitOccurrenceStatus status = HabitOccurrenceStatus.pending,
    DateTime? completedAt,
  }) {
    return HabitOccurrence(
      id: 1,
      habitId: 2,
      scheduledDate: scheduledDate,
      completedAt: completedAt,
      status: status,
      createdAt: createdAt,
    );
  }

  

  group('CompleteHabitOccurrence', () {
    test('sets status to completed and records completedAt', () async {
      final occurrence = buildOccurrence();

      when(() => repository.updateOccurrence(any())).thenAnswer(
        (invocation) async {
          final updatedOccurrence =
              invocation.positionalArguments.first as HabitOccurrence;

          return Right(updatedOccurrence);
        },
      );

      final result = await completeOccurrence(occurrence);

      expect(result.isRight(), isTrue);

      final updatedOccurrence = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedOccurrence.status, HabitOccurrenceStatus.completed);
      expect(updatedOccurrence.completedAt, isNotNull);
      expect(updatedOccurrence.scheduledDate, scheduledDate);

      verify(() => repository.updateOccurrence(any())).called(1);
    });

    test('propagates repository failure', () async {
      const failure = DatabaseFailure(
        'Unable to complete occurrence.',
      );

      when(() => repository.updateOccurrence(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await completeOccurrence(buildOccurrence());

      expect(
        result,
        const Left<Failure, HabitOccurrence>(failure),
      );

      verify(() => repository.updateOccurrence(any())).called(1);
    });
  });

  group('SkipHabitOccurrence', () {
    test('sets status to skipped and clears completedAt', () async {
      final occurrence = buildOccurrence(
        status: HabitOccurrenceStatus.completed,
        completedAt: DateTime(2026, 1, 2, 10),
      );

      when(() => repository.updateOccurrence(any())).thenAnswer(
        (invocation) async {
          final updatedOccurrence =
              invocation.positionalArguments.first as HabitOccurrence;

          return Right(updatedOccurrence);
        },
      );

      final result = await skipOccurrence(occurrence);

      expect(result.isRight(), isTrue);

      final updatedOccurrence = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedOccurrence.status, HabitOccurrenceStatus.skipped);
      expect(updatedOccurrence.completedAt, isNull);
      expect(updatedOccurrence.scheduledDate, scheduledDate);

      verify(() => repository.updateOccurrence(any())).called(1);
    });

    test('propagates repository failure', () async {
      const failure = DatabaseFailure(
        'Unable to skip occurrence.',
      );

      when(() => repository.updateOccurrence(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await skipOccurrence(buildOccurrence());

      expect(
        result,
        const Left<Failure, HabitOccurrence>(failure),
      );

      verify(() => repository.updateOccurrence(any())).called(1);
    });
  });
}