import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:mocktail/mocktail.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/activities/domain/entities/activity.dart';
import 'package:corelog/features/activities/domain/repositories/activity_repository.dart';
import 'package:corelog/features/home/domain/entities/home_dashboard.dart';
import 'package:corelog/features/home/domain/usecases/get_home_dashboard.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockTaskExecutionSessionRepository extends Mock
    implements TaskExecutionSessionRepository {}

class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  late MockTaskRepository taskRepository;
  late MockTaskExecutionSessionRepository sessionRepository;
  late MockActivityRepository activityRepository;
  late GetHomeDashboard getHomeDashboard;

  final now = DateTime(2026, 9, 30, 12);

  setUp(() {
    taskRepository = MockTaskRepository();
    sessionRepository = MockTaskExecutionSessionRepository();
    activityRepository = MockActivityRepository();

    getHomeDashboard = GetHomeDashboard(
      taskRepository: taskRepository,
      sessionRepository: sessionRepository,
      activityRepository: activityRepository,
    );
  });

  Task task({
    required int id,
    required String title,
    TaskStatus status = TaskStatus.pending,
    int? activityId,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title,
      status: status,
      activityId: activityId,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      completedAt: completedAt,
      createdAt: DateTime(2026, 9, 29),
      updatedAt: now,
    );
  }

  Activity activity({
    required int id,
    required String name,
  }) {
    return Activity(
      id: id,
      name: name,
      isActive: true,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: now,
    );
  }

  TaskExecutionSession session({
    required int id,
    required int taskId,
    required DateTime startedAt,
    DateTime? endedAt,
  }) {
    return TaskExecutionSession(
      id: id,
      taskId: taskId,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  group('GetHomeDashboard', () {
    test('returns zero values when there are no tasks today', () async {
      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => const Right([]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => const Right([]),
      );

      final result = await getHomeDashboard(now);

      expect(
        result,
        const Right(
          HomeDashboard(
            completedTaskCount: 0,
            totalTaskCount: 0,
            plannedDuration: Duration.zero,
            actualDuration: Duration.zero,
            activityBreakdown: {},
            recentCompletedTasks: [],
          ),
        ),
      );
    });

    test('counts scheduled tasks planned for today', () async {
      final todayTask = task(
        id: 1,
        title: 'Build dashboard',
        plannedStart: DateTime(2026, 9, 30, 10),
        plannedEnd: DateTime(2026, 9, 30, 11),
      );

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => Right([todayTask]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => const Right([]),
      );

      when(() => sessionRepository.getSessionsByTask(1)).thenAnswer(
        (_) async => const Right([]),
      );

      final result = await getHomeDashboard(now);

      expect(
        result,
        const Right(
          HomeDashboard(
            completedTaskCount: 0,
            totalTaskCount: 1,
            plannedDuration: Duration(hours: 1),
            actualDuration: Duration.zero,
            activityBreakdown: {},
            recentCompletedTasks: [],
          ),
        ),
      );
    });

    test('counts tasks completed today', () async {
      final completedTask = task(
        id: 1,
        title: 'Finish API work',
        status: TaskStatus.completed,
        completedAt: DateTime(2026, 9, 30, 11),
      );

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => Right([completedTask]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => const Right([]),
      );

      when(() => sessionRepository.getSessionsByTask(1)).thenAnswer(
        (_) async => const Right([]),
      );

      final result = await getHomeDashboard(now);

      expect(
        result,
        const Right(
          HomeDashboard(
            completedTaskCount: 1,
            totalTaskCount: 1,
            plannedDuration: Duration.zero,
            actualDuration: Duration.zero,
            activityBreakdown: {},
            recentCompletedTasks: ['Finish API work'],
          ),
        ),
      );
    });

    test('calculates actual active time from execution sessions', () async {
      final todayTask = task(
        id: 1,
        title: 'Build feature',
        activityId: 10,
        plannedStart: DateTime(2026, 9, 30, 10),
        plannedEnd: DateTime(2026, 9, 30, 12),
      );

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => Right([todayTask]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => Right([
          activity(
            id: 10,
            name: 'Flutter Development',
          ),
        ]),
      );

      when(() => sessionRepository.getSessionsByTask(1)).thenAnswer(
        (_) async => Right([
          session(
            id: 1,
            taskId: 1,
            startedAt: DateTime(2026, 9, 30, 10),
            endedAt: DateTime(2026, 9, 30, 10, 40),
          ),
          session(
            id: 2,
            taskId: 1,
            startedAt: DateTime(2026, 9, 30, 11),
            endedAt: DateTime(2026, 9, 30, 11, 20),
          ),
        ]),
      );

      final result = await getHomeDashboard(now);

      expect(
        result,
        const Right(
          HomeDashboard(
            completedTaskCount: 0,
            totalTaskCount: 1,
            plannedDuration: Duration(hours: 2),
            actualDuration: Duration(minutes: 60),
            activityBreakdown: {
              'Flutter Development': Duration(minutes: 60),
            },
            recentCompletedTasks: [],
          ),
        ),
      );
    });

    test('includes currently active session in actual time', () async {
      final todayTask = task(
        id: 1,
        title: 'Continue feature',
        plannedStart: DateTime(2026, 9, 30, 10),
        plannedEnd: DateTime(2026, 9, 30, 13),
      );

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => Right([todayTask]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => const Right([]),
      );

      when(() => sessionRepository.getSessionsByTask(1)).thenAnswer(
        (_) async => Right([
          session(
            id: 1,
            taskId: 1,
            startedAt: DateTime(2026, 9, 30, 11),
          ),
        ]),
      );

      final result = await getHomeDashboard(now);

      expect(
        result,
        const Right(
          HomeDashboard(
            completedTaskCount: 0,
            totalTaskCount: 1,
            plannedDuration: Duration(hours: 3),
            actualDuration: Duration(hours: 1),
            activityBreakdown: {'Uncategorized': Duration(hours: 1),},
            recentCompletedTasks: [],
          ),
        ),
      );
    });

    test('ignores tasks completed on another day', () async {
      final completedYesterday = task(
        id: 1,
        title: 'Yesterday task',
        status: TaskStatus.completed,
        completedAt: DateTime(2026, 9, 29, 15),
      );

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => Right([completedYesterday]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => const Right([]),
      );

      final result = await getHomeDashboard(now);

      expect(
        result,
        const Right(
          HomeDashboard(
            completedTaskCount: 0,
            totalTaskCount: 0,
            plannedDuration: Duration.zero,
            actualDuration: Duration.zero,
            activityBreakdown: {},
            recentCompletedTasks: [],
          ),
        ),
      );
    });

    test('propagates task repository failure', () async {
      const failure = DatabaseFailure('Could not load tasks.');

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await getHomeDashboard(now);

      expect(result, const Left(failure));

      verifyNever(() => activityRepository.getActivities());
    });

    test('propagates activity repository failure', () async {
      const failure = DatabaseFailure('Could not load activities.');

      when(() => taskRepository.getTasks()).thenAnswer(
        (_) async => const Right([]),
      );

      when(() => activityRepository.getActivities()).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await getHomeDashboard(now);

      expect(result, const Left(failure));
    });

    test('propagates session repository failure', () async {
  final task = Task(
    id: 1,
    title: 'Flutter Development',
    status: TaskStatus.pending,
    createdAt: DateTime(2026, 9, 30, 8),
    updatedAt: DateTime(2026, 9, 30, 8),
    plannedStart: DateTime(2026, 9, 30, 9),
    plannedEnd: DateTime(2026, 9, 30, 10),
  );

  const failure = DatabaseFailure(
    'Could not load task execution sessions.',
  );

  when(() => taskRepository.getTasks()).thenAnswer(
    (_) async => Right([task]),
  );

  when(() => activityRepository.getActivities()).thenAnswer(
    (_) async => const Right([]),
  );

  when(() => sessionRepository.getSessionsByTask(1)).thenAnswer(
    (_) async => const Left(failure),
  );

  final result = await getHomeDashboard(
    DateTime(2026, 9, 30, 12),
  );

  expect(result, const Left(failure));
});
  });
}