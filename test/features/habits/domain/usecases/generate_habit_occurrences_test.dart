import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence_status.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';
import 'package:corelog/features/habits/domain/usecases/generate_habit_occurrences.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

class MockHabitOccurrenceRepository extends Mock
    implements HabitOccurrenceRepository {}

void main() {
  late MockHabitRepository habitRepository;
  late MockHabitOccurrenceRepository occurrenceRepository;
  late GenerateHabitOccurrences generateOccurrences;

  setUpAll(() {
    registerFallbackValue(
      Habit(
        id: 0,
        name: 'Fallback',
        weekdayMask: 127,
        isActive: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

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
    habitRepository = MockHabitRepository();
    occurrenceRepository = MockHabitOccurrenceRepository();

    generateOccurrences = GenerateHabitOccurrences(
      habitRepository: habitRepository,
      occurrenceRepository: occurrenceRepository,
    );
  });

  Habit createHabit({
    required int id,
    int weekdayMask = 127,
    bool isActive = true,
    DateTime? targetTime,
  }) {
    return Habit(
      id: id,
      name: 'Test Habit',
      weekdayMask: weekdayMask,
      targetTime: targetTime,
      isActive: isActive,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  test(
    'generates occurrences only for scheduled weekdays',
    () async {
      final monday = DateTime(
        2026,
        9,
        28,
      );

      when(() => habitRepository.getHabits()).thenAnswer(
        (_) async => Right([
          createHabit(
            id: 1,
            weekdayMask: 1,
          ),
        ]),
      );

      when(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => const Right(null),
      );

      when(
        () => occurrenceRepository.createOccurrence(any()),
      ).thenAnswer(
        (invocation) async {
          final occurrence =
              invocation.positionalArguments.first as HabitOccurrence;

          return Right(occurrence);
        },
      );

      final result = await generateOccurrences.call(
        from: monday,
      );

      expect(result.isRight(), isTrue);

      final capturedOccurrences = verify(
        () => occurrenceRepository.createOccurrence(captureAny()),
      ).captured;

      expect(capturedOccurrences, hasLength(1));

      final occurrence =
          capturedOccurrences.single as HabitOccurrence;

      expect(
        occurrence.scheduledDate,
        DateTime(2026, 9, 28),
      );
    },
  );

  test(
    'does not generate occurrences for inactive habits',
    () async {
      final monday = DateTime(
        2026,
        9,
        28,
      );

      when(() => habitRepository.getHabits()).thenAnswer(
        (_) async => Right([
          createHabit(
            id: 1,
            isActive: false,
          ),
        ]),
      );

      final result = await generateOccurrences.call(
        from: monday,
      );

      expect(result.isRight(), isTrue);

      verifyNever(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          any(),
          any(),
        ),
      );

      verifyNever(
        () => occurrenceRepository.createOccurrence(any()),
      );
    },
  );

  test(
    'uses the habit target time for generated occurrences',
    () async {
      final monday = DateTime(
        2026,
        9,
        28,
      );

      when(() => habitRepository.getHabits()).thenAnswer(
        (_) async => Right([
          createHabit(
            id: 1,
            weekdayMask: 1,
            targetTime: DateTime(
              2026,
              9,
              28,
              7,
              30,
            ),
          ),
        ]),
      );

      when(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => const Right(null),
      );

      when(
        () => occurrenceRepository.createOccurrence(any()),
      ).thenAnswer(
        (invocation) async {
          final occurrence =
              invocation.positionalArguments.first as HabitOccurrence;

          return Right(occurrence);
        },
      );

      await generateOccurrences.call(
        from: monday,
      );

      final capturedOccurrences = verify(
        () => occurrenceRepository.createOccurrence(captureAny()),
      ).captured;

      final occurrence =
          capturedOccurrences.single as HabitOccurrence;

      expect(
        occurrence.scheduledDate,
        DateTime(
          2026,
          9,
          28,
          7,
          30,
        ),
      );
    },
  );

  test(
    'does not create a duplicate occurrence when one already exists',
    () async {
      final monday = DateTime(
        2026,
        9,
        28,
      );

      final existingOccurrence = HabitOccurrence(
        id: 10,
        habitId: 1,
        scheduledDate: monday,
        status: HabitOccurrenceStatus.completed,
        completedAt: DateTime(
          2026,
          9,
          28,
          8,
        ),
        createdAt: monday,
      );

      when(() => habitRepository.getHabits()).thenAnswer(
        (_) async => Right([
          createHabit(
            id: 1,
            weekdayMask: 1,
          ),
        ]),
      );

      when(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => Right(existingOccurrence),
      );

      final result = await generateOccurrences.call(
        from: monday,
      );

      expect(result.isRight(), isTrue);

      verify(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          1,
          monday,
        ),
      ).called(1);

      verifyNever(
        () => occurrenceRepository.createOccurrence(any()),
      );
    },
  );

  test(
    'propagates occurrence lookup failure',
    () async {
      final monday = DateTime(
        2026,
        9,
        28,
      );

      const failure = DatabaseFailure(
        'Could not read occurrences.',
      );

      when(() => habitRepository.getHabits()).thenAnswer(
        (_) async => Right([
          createHabit(
            id: 1,
            weekdayMask: 1,
          ),
        ]),
      );

      when(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await generateOccurrences.call(
        from: monday,
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (error) => expect(error, failure),
        (_) => fail('Expected a failure.'),
      );

      verifyNever(
        () => occurrenceRepository.createOccurrence(any()),
      );
    },
  );

  test(
    'propagates occurrence creation failure',
    () async {
      final monday = DateTime(
        2026,
        9,
        28,
      );

      const failure = DatabaseFailure(
        'Could not create occurrence.',
      );

      when(() => habitRepository.getHabits()).thenAnswer(
        (_) async => Right([
          createHabit(
            id: 1,
            weekdayMask: 1,
          ),
        ]),
      );

      when(
        () => occurrenceRepository.getOccurrenceByHabitAndDate(
          any(),
          any(),
        ),
      ).thenAnswer(
        (_) async => const Right(null),
      );

      when(
        () => occurrenceRepository.createOccurrence(any()),
      ).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await generateOccurrences.call(
        from: monday,
      );

      expect(result.isLeft(), isTrue);

      result.match(
        (error) => expect(error, failure),
        (_) => fail('Expected a failure.'),
      );
    },
  );

test(
  'generates occurrences across the seven-day window',
  () async {
    final monday = DateTime(
      2026,
      9,
      28,
    );

    when(() => habitRepository.getHabits()).thenAnswer(
      (_) async => Right([
        createHabit(
          id: 1,
          weekdayMask: 127,
        ),
      ]),
    );

    when(
      () => occurrenceRepository.getOccurrenceByHabitAndDate(
        any(),
        any(),
      ),
    ).thenAnswer(
      (_) async => const Right(null),
    );

    when(
      () => occurrenceRepository.createOccurrence(any()),
    ).thenAnswer(
      (invocation) async {
        final occurrence =
            invocation.positionalArguments.first as HabitOccurrence;

        return Right(occurrence);
      },
    );

    final result = await generateOccurrences.call(
      from: monday,
    );

    expect(result.isRight(), isTrue);

    final capturedOccurrences = verify(
      () => occurrenceRepository.createOccurrence(captureAny()),
    ).captured;

    expect(capturedOccurrences, hasLength(7));

    final scheduledDates = capturedOccurrences
        .cast<HabitOccurrence>()
        .map((occurrence) => occurrence.scheduledDate)
        .toList();

    expect(
      scheduledDates,
      [
        DateTime(2026, 9, 28),
        DateTime(2026, 9, 29),
        DateTime(2026, 9, 30),
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3),
        DateTime(2026, 10, 4),
      ],
    );
  },
);
}