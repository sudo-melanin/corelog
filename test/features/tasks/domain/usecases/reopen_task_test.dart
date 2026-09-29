import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/reopen_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late ReopenTask reopenTask;

  setUpAll(() {
    registerFallbackValue(
      Task(
        id: 0,
        title: 'Fallback task',
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    taskRepository = MockTaskRepository();
    reopenTask = ReopenTask(taskRepository);
  });

  Task buildTask({
    int id = 1,
    TaskStatus status = TaskStatus.completed,
    int? activityId,
    String title = 'Test task',
    String? description = 'Test description',
    DateTime? dueDate,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    DateTime? completedAt,
    DateTime? skippedAt,
    TaskSkipReason? skipReason,
    String? skipNote,
  }) {
    final now = DateTime(2026, 1, 1, 10);

    return Task(
      id: id,
      activityId: activityId,
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      completedAt: completedAt,
      skippedAt: skippedAt,
      skipReason: skipReason,
      skipNote: skipNote,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ReopenTask', () {
    test('reopens completed task as pending', () async {
      final task = buildTask(
        status: TaskStatus.completed,
        plannedStart: DateTime(2026, 1, 12, 14),
        plannedEnd: DateTime(2026, 1, 12, 15),
        completedAt: DateTime(2026, 1, 12, 15, 30),
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((invocation) async {
        final reopenedTask =
            invocation.positionalArguments.first as Task;

        return Right(reopenedTask);
      });

      final result = await reopenTask(task);

      expect(result.isRight(), isTrue);

      final reopenedTask = result.getOrElse(
        (_) => throw StateError('Expected reopen to succeed.'),
      );

      expect(reopenedTask.id, task.id);
      expect(reopenedTask.status, TaskStatus.pending);
      expect(reopenedTask.completedAt, isNull);
      expect(reopenedTask.plannedStart, task.plannedStart);
      expect(reopenedTask.plannedEnd, task.plannedEnd);

      verify(
        () => taskRepository.updateTask(any()),
      ).called(1);
    });

    test('propagates task repository failure', () async {
      final task = buildTask(
        status: TaskStatus.completed,
      );

      const failure = DatabaseFailure(
        'Failed to reopen task.',
      );

      when(() => taskRepository.updateTask(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await reopenTask(task);

      expect(
        result,
        const Left<Failure, Task>(failure),
      );

      verify(
        () => taskRepository.updateTask(any()),
      ).called(1);
    });
  });
}