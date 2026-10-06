import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_time_formatter.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_timing.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';

class TaskCardTiming extends ConsumerStatefulWidget {
  const TaskCardTiming({
    required this.task,
    super.key,
  });

  final Task task;

  @override
  ConsumerState<TaskCardTiming> createState() => _TaskCardTimingState();
}

class _TaskCardTimingState extends ConsumerState<TaskCardTiming> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TaskCardTiming oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.task.status != widget.task.status ||
        oldWidget.task.plannedEnd != widget.task.plannedEnd) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.task.status == TaskStatus.paused) {
      _now = DateTime.now();
      return;
    }

    if (widget.task.plannedEnd == null) {
      _now = DateTime.now();
      return;
    }

    _now = DateTime.now();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _now = DateTime.now();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    if (task.plannedStart == null || task.plannedEnd == null) {
      return Text(
        'Unscheduled',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    final sessionsAsync = ref.watch(
      taskExecutionSessionsProvider(task.id),
    );

    return sessionsAsync.when(
      loading: () => _buildPlannedSchedule(context),
      error: (_, _) => _buildPlannedSchedule(context),
      data: (sessions) {
        final actualStart = TaskTiming.actualStart(sessions);
        final pausedAt = task.status == TaskStatus.paused
            ? TaskTiming.latestPause(sessions)
            : null;

        return _buildTiming(
          context,
          actualStart: actualStart,
          pausedAt: pausedAt,
        );
      },
    );
  }

  Widget _buildTiming(
    BuildContext context, {
    required DateTime? actualStart,
    required DateTime? pausedAt,
  }) {
    final task = widget.task;

    final isOverdue = TaskTiming.isOverdue(
      task,
      now: _now,
    );

    final remaining = TaskTiming.remaining(
      task,
      now: _now,
      pausedAt: pausedAt,
    );

    final overdueDuration = TaskTiming.overdueDuration(
      task,
      now: _now,
      pausedAt: pausedAt,
    );

    if (actualStart != null) {
      final deviation = TaskTimeFormatter.startDeviation(
        task.plannedStart!,
        actualStart,
      );

      final timingText = isOverdue
          ? '${TaskTimeFormatter.duration(overdueDuration!)} overdue'
          : '${TaskTimeFormatter.duration(remaining!)} remaining';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Started ${TaskTimeFormatter.time(actualStart)} · $deviation',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            timingText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverdue
                      ? AppColors.error
                      : task.status == TaskStatus.paused
                          ? AppColors.warning
                          : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    if (isOverdue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TaskTimeFormatter.time(task.plannedStart!)} - '
            '${TaskTimeFormatter.time(task.plannedEnd!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${TaskTimeFormatter.duration(overdueDuration!)} overdue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    if (task.status == TaskStatus.inProgress ||
        task.status == TaskStatus.paused) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${TaskTimeFormatter.time(task.plannedStart!)} - '
            '${TaskTimeFormatter.time(task.plannedEnd!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${TaskTimeFormatter.duration(remaining!)} remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: task.status == TaskStatus.paused
                      ? AppColors.warning
                      : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    return _buildPlannedSchedule(context);
  }

  Widget _buildPlannedSchedule(BuildContext context) {
    final task = widget.task;

    return Text(
      '${TaskTimeFormatter.time(task.plannedStart!)} - '
      '${TaskTimeFormatter.time(task.plannedEnd!)}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}