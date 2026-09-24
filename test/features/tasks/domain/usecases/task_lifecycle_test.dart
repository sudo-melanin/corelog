import 'package:fpdart/fpdart.dart' hide Task;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';
import 'package:corelog/features/tasks/domain/usecases/complete_task.dart';
import 'package:corelog/features/tasks/domain/usecases/reopen_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository repository;
  late CompleteTask completeTask;
  late ReopenTask reopenTask;

  setUpAll(() {
  registerFallbackValue(
    Task(
      id: 0,
      title: '',
      status: TaskStatus.pending,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
});
  
  setUp(() {
    repository = MockTaskRepository();
    completeTask = CompleteTask(repository);
    reopenTask = ReopenTask(repository);
  });

  final createdAt = DateTime(2026, 1, 1, 9);
  final updatedAt = DateTime(2026, 1, 1, 10);

  Task buildTask({
    TaskStatus status = TaskStatus.pending,
    DateTime? completedAt,
  }) {
    return Task(
      id: 1,
      projectId: 2,
      title: 'Study Flutter',
      description: 'Work on CoreLog',
      status: status,
      dueDate: DateTime(2026, 1, 1, 18),
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  

  group('CompleteTask', () {
    test('sets status to completed and records completedAt', () async {
      final task = buildTask();

      when(() => repository.updateTask(any())).thenAnswer(
        (invocation) async {
          final updatedTask =
              invocation.positionalArguments.first as Task;

          return Right(updatedTask);
        },
      );

      final result = await completeTask(task);

      expect(result.isRight(), isTrue);

      final updatedTask = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTask.status, TaskStatus.completed);
      expect(updatedTask.completedAt, isNotNull);
      expect(updatedTask.id, task.id);
      expect(updatedTask.title, task.title);

      verify(() => repository.updateTask(any())).called(1);
    });

    test('propagates repository failure', () async {
      const failure = DatabaseFailure('Unable to update task.');

      when(() => repository.updateTask(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await completeTask(buildTask());

      expect(result, const Left<Failure, Task>(failure));

      verify(() => repository.updateTask(any())).called(1);
    });
  });

  group('ReopenTask', () {
    test('sets status to pending and clears completedAt', () async {
      final task = buildTask(
        status: TaskStatus.completed,
        completedAt: DateTime(2026, 1, 1, 11),
      );

      when(() => repository.updateTask(any())).thenAnswer(
        (invocation) async {
          final updatedTask =
              invocation.positionalArguments.first as Task;

          return Right(updatedTask);
        },
      );

      final result = await reopenTask(task);

      expect(result.isRight(), isTrue);

      final updatedTask = result.getOrElse(
        (failure) => throw StateError(failure.message),
      );

      expect(updatedTask.status, TaskStatus.pending);
      expect(updatedTask.completedAt, isNull);
      expect(updatedTask.id, task.id);
      expect(updatedTask.title, task.title);

      verify(() => repository.updateTask(any())).called(1);
    });

    test('propagates repository failure', () async {
      const failure = DatabaseFailure('Unable to reopen task.');

      when(() => repository.updateTask(any())).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await reopenTask(
        buildTask(
          status: TaskStatus.completed,
          completedAt: DateTime(2026, 1, 1, 11),
        ),
      );

      expect(result, const Left<Failure, Task>(failure));

      verify(() => repository.updateTask(any())).called(1);
    });
  });
}