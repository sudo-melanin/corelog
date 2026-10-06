import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_execution_session.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_time_formatter.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_timing.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/tasks/presentation/widgets/task_status_chip.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({
    required this.task,
    super.key,
  });

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(
      taskExecutionSessionsProvider(task.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),
            _buildSchedule(context),
            const SizedBox(height: AppSpacing.lg),
            sessionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => const Text(
                'Execution details could not be loaded.',
              ),
              data: (sessions) => _buildExecution(
                context,
                sessions,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildOutcome(context),
            if (task.description != null &&
                task.description!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildDescription(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TaskStatusChip(status: task.status),
      ],
    );
  }

  Widget _buildSchedule(BuildContext context) {
    final plannedStart = task.plannedStart;
    final plannedEnd = task.plannedEnd;

    if (plannedStart == null || plannedEnd == null) {
      return Text(
        'Unscheduled',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final plannedDuration = plannedEnd.difference(plannedStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${TaskTimeFormatter.time(plannedStart)} - '
          '${TaskTimeFormatter.time(plannedEnd)}',
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${TaskTimeFormatter.duration(plannedDuration)} planned',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildExecution(
    BuildContext context,
    List<TaskExecutionSession> sessions,
  ) {
    final actualStart = TaskTiming.actualStart(sessions);

    var actualDuration = Duration.zero;

    for (final session in sessions) {
      if (session.endedAt != null) {
        actualDuration += session.endedAt!.difference(
          session.startedAt,
        );
      }
    }

    final plannedStart = task.plannedStart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (actualStart != null) ...[
          Text(
            'Started ${TaskTimeFormatter.time(actualStart)}',
          ),
          if (plannedStart != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              TaskTimeFormatter.startDeviation(
                plannedStart,
                actualStart,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(
          '${TaskTimeFormatter.duration(actualDuration)} active',
        ),
        if (sessions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sessions',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sessions.map(
            (session) => _buildSession(
              context,
              session,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSession(
    BuildContext context,
    TaskExecutionSession session,
  ) {
    final endedAt = session.endedAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        endedAt == null
            ? '${TaskTimeFormatter.time(session.startedAt)} - Active'
            : '${TaskTimeFormatter.time(session.startedAt)} - '
                '${TaskTimeFormatter.time(endedAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildOutcome(BuildContext context) {
    if (task.status == TaskStatus.completed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outcome',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (task.completedAt != null)
            Text(
              'Completed ${TaskTimeFormatter.time(task.completedAt!)}',
            ),
        ],
      );
    }

    if (task.status == TaskStatus.skipped) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outcome',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (task.skippedAt != null)
            Text(
              'Skipped ${TaskTimeFormatter.time(task.skippedAt!)}',
            ),
          if (task.skipReason != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Reason: ${task.skipReason}',
            ),
          ],
          if (task.skipNote != null &&
              task.skipNote!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(task.skipNote!),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(task.description!),
      ],
    );
  }
}