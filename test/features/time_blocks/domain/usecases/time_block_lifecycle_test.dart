import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';
import 'package:corelog/features/time_blocks/domain/usecases/complete_time_block.dart';
import 'package:corelog/features/time_blocks/domain/usecases/skip_time_block.dart';
import 'package:corelog/features/time_blocks/domain/usecases/start_time_block.dart';

class MockTimeBlockRepository extends Mock
    implements TimeBlockRepository {}

void main() {
  late MockTimeBlockRepository repository;
  late StartTimeBlock startTimeBlock;
  late CompleteTimeBlock completeTimeBlock;
  late SkipTimeBlock skipTimeBlock;

  setUpAll(() {
  registerFallbackValue(
    TimeBlock(
      id: 0,
      projectId: 0,
      plannedStart: DateTime(2026),
      plannedEnd: DateTime(2026, 1, 1, 1),
      status: TimeBlockStatus.planned,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
});

  setUp(() {
    repository = MockTimeBlockRepository();
    startTimeBlock = StartTimeBlock(repository);
    completeTimeBlock = CompleteTimeBlock(repository);
    skipTimeBlock = SkipTimeBlock(repository);
  });

  final createdAt = DateTime(2026, 1, 1, 9);
  final plannedStart = DateTime(2026, 1, 1, 10);
  final plannedEnd = DateTime(2026, 1, 1, 11);

  TimeBlock buildTimeBlock({
    TimeBlockStatus status = TimeBlockStatus.planned,
    DateTime? actualStart,
    DateTime? actualEnd,
  }) {
    return TimeBlock(
      id: 1,
      projectId: 2,
      taskId: 3,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      actualStart: actualStart,
      actualEnd: actualEnd,
      status: status,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  void stubSuccessfulUpdate() {
    when(() => repository.updateTimeBlock(any())).thenAnswer(
      (invocation) async {
        final updatedTimeBlock =
            invocation.positionalArguments.first as TimeBlock;

        return Right(updatedTimeBlock);
      },
    );
  }

  group('StartTimeBlock', () {
    test('sets status to inProgress and records actualStart', () async {
      final timeBlock = buildTimeBlock();

      stubSuccessfulUpdate();

      final result = await startTimeBlock(timeBlock);

      expect(result.isRight(), isTrue);

      final updatedTimeBlock = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTimeBlock.status, TimeBlockStatus.inProgress);
      expect(updatedTimeBlock.actualStart, isNotNull);
      expect(updatedTimeBlock.plannedStart, plannedStart);
      expect(updatedTimeBlock.plannedEnd, plannedEnd);

      verify(() => repository.updateTimeBlock(any())).called(1);
    });
  });

  group('CompleteTimeBlock', () {
    test('sets status to completed and records actualEnd', () async {
      final actualStart = DateTime(2026, 1, 1, 10, 5);
      final timeBlock = buildTimeBlock(
        status: TimeBlockStatus.inProgress,
        actualStart: actualStart,
      );

      stubSuccessfulUpdate();

      final result = await completeTimeBlock(timeBlock);

      expect(result.isRight(), isTrue);

      final updatedTimeBlock = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTimeBlock.status, TimeBlockStatus.completed);
      expect(updatedTimeBlock.actualStart, actualStart);
      expect(updatedTimeBlock.actualEnd, isNotNull);
      expect(updatedTimeBlock.plannedStart, plannedStart);
      expect(updatedTimeBlock.plannedEnd, plannedEnd);

      verify(() => repository.updateTimeBlock(any())).called(1);
    });
  });

  group('SkipTimeBlock', () {
    test('sets status to skipped without changing planned or actual times',
        () async {
      final actualStart = DateTime(2026, 1, 1, 10, 5);
      final actualEnd = DateTime(2026, 1, 1, 10, 45);

      final timeBlock = buildTimeBlock(
        status: TimeBlockStatus.inProgress,
        actualStart: actualStart,
        actualEnd: actualEnd,
      );

      stubSuccessfulUpdate();

      final result = await skipTimeBlock(timeBlock);

      expect(result.isRight(), isTrue);

      final updatedTimeBlock = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTimeBlock.status, TimeBlockStatus.skipped);
      expect(updatedTimeBlock.actualStart, actualStart);
      expect(updatedTimeBlock.actualEnd, actualEnd);
      expect(updatedTimeBlock.plannedStart, plannedStart);
      expect(updatedTimeBlock.plannedEnd, plannedEnd);

      verify(() => repository.updateTimeBlock(any())).called(1);
    });

    test('propagates repository failure', () async {
      const failure = DatabaseFailure(
        'Unable to skip time block.',
      );

      when(() => repository.updateTimeBlock(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await skipTimeBlock(buildTimeBlock());

      expect(
        result,
        const Left<Failure, TimeBlock>(failure),
      );

      verify(() => repository.updateTimeBlock(any())).called(1);
    });
  });
}