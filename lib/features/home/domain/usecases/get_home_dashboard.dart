import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/activities/domain/repositories/activity_repository.dart';
import 'package:corelog/features/home/domain/entities/home_dashboard.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/domain/repositories/task_execution_session_repository.dart';
import 'package:corelog/features/tasks/domain/repositories/task_repository.dart';

import '../../../tasks/domain/entities/task_execution_session.dart';

class GetHomeDashboard {
  const GetHomeDashboard({
    required this._taskRepository,
    required this._sessionRepository,
    required this._activityRepository,
  });

  final TaskRepository _taskRepository;
  final TaskExecutionSessionRepository _sessionRepository;
  final ActivityRepository _activityRepository;

  Future<Either<Failure, HomeDashboard>> call(DateTime now) async {
    final tasksResult = await _taskRepository.getTasks();

    return tasksResult.match(Left.new, (tasks) async {
      final activitiesResult = await _activityRepository.getActivities();

      return activitiesResult.match(Left.new, (activities) async {
        final startOfToday = DateTime(now.year, now.month, now.day);

        final startOfTomorrow = startOfToday.add(const Duration(days: 1));

        final todayTasks = tasks.where((task) {
          final completedToday =
              task.status == TaskStatus.completed &&
              task.completedAt != null &&
              !task.completedAt!.isBefore(startOfToday) &&
              task.completedAt!.isBefore(startOfTomorrow);

          final scheduledToday =
              task.plannedStart != null &&
              task.plannedEnd != null &&
              task.plannedStart!.isBefore(startOfTomorrow) &&
              task.plannedEnd!.isAfter(startOfToday);

          return completedToday || scheduledToday;
        }).toList();

        var plannedDuration = Duration.zero;

        for (final task in todayTasks) {
          if (task.plannedStart != null && task.plannedEnd != null) {
            plannedDuration += task.plannedEnd!.difference(task.plannedStart!);
          }
        }

        var actualDuration = Duration.zero;
        final activityBreakdown = <String, Duration>{};

        for (final task in todayTasks) {
          final sessionsResult = await _sessionRepository.getSessionsByTask(
            task.id,
          );

          final sessions = <TaskExecutionSession>[];

          final sessionFailure = sessionsResult.fold((failure) => failure, (
            loadedSessions,
          ) {
            sessions.addAll(loadedSessions);
            return null;
          });

          if (sessionFailure != null) {
            return left(sessionFailure);
          }

          for (final session in sessions) {
            final endedAt = session.endedAt ?? now;

            if (session.startedAt.isBefore(startOfTomorrow) &&
                endedAt.isAfter(startOfToday)) {
              final sessionStart = session.startedAt.isBefore(startOfToday)
                  ? startOfToday
                  : session.startedAt;

              final sessionEnd = endedAt.isAfter(startOfTomorrow)
                  ? startOfTomorrow
                  : endedAt;

              final duration = sessionEnd.difference(sessionStart);

              if (duration.isNegative) {
                continue;
              }

              actualDuration += duration;

              final activityName =
                  activities
                      .where((activity) => activity.id == task.activityId)
                      .map((activity) => activity.name)
                      .firstOrNull ??
                  'Uncategorized';

              activityBreakdown[activityName] =
                  (activityBreakdown[activityName] ?? Duration.zero) + duration;
            }
          }
        }

        final completedTasks =
            todayTasks
                .where((task) => task.status == TaskStatus.completed)
                .toList()
              ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

        return Right(
          HomeDashboard(
            completedTaskCount: completedTasks.length,
            totalTaskCount: todayTasks.length,
            plannedDuration: plannedDuration,
            actualDuration: actualDuration,
            activityBreakdown: activityBreakdown,
            recentCompletedTasks: completedTasks
                .take(5)
                .map((task) => task.title)
                .toList(),
          ),
        );
      });
    });
  }
}
