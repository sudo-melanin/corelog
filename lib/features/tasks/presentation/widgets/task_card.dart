import 'dart:async';

import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    required this.task,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onComplete,
    required this.onSkip,
    required this.onReopen,
    super.key,
  });

  final Task task;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onReopen;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
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

    if (!_needsLiveTime(widget.task)) {
      return;
    }

    _now = DateTime.now();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _now = DateTime.now();
        });
      },
    );
  }

  bool _needsLiveTime(Task task) {
    return task.plannedEnd != null &&
        (task.status == TaskStatus.pending ||
            task.status == TaskStatus.inProgress);
  }

  bool get _isOverdue {
    final plannedEnd = widget.task.plannedEnd;

    if (plannedEnd == null) {
      return false;
    }

    return widget.task.status == TaskStatus.pending &&
        _now.isAfter(plannedEnd);
  }

  Duration? get _remaining {
    final plannedEnd = widget.task.plannedEnd;

    if (plannedEnd == null) {
      return null;
    }

    final difference = plannedEnd.difference(_now);

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  Duration? get _overdueDuration {
    final plannedEnd = widget.task.plannedEnd;

    if (plannedEnd == null || !_isOverdue) {
      return null;
    }

    return _now.difference(plannedEnd);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _isOverdue ? AppColors.warning : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TaskStatusChip(status: task.status),
            ],
          ),
          if (task.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              task.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _buildSchedule(context),
          const SizedBox(height: AppSpacing.md),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildSchedule(BuildContext context) {
    final task = widget.task;

    if (task.plannedStart == null || task.plannedEnd == null) {
      return Text(
        'Unscheduled',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    if (_isOverdue) {
      return Text(
        'Overdue by ${_formatDuration(_overdueDuration!)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    if (task.status == TaskStatus.inProgress) {
      return Text(
        '${_formatTime(task.plannedStart!)} - '
        '${_formatTime(task.plannedEnd!)} • '
        '${_formatDuration(_remaining!)} remaining',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    return Text(
      '${_formatTime(task.plannedStart!)} - '
      '${_formatTime(task.plannedEnd!)}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildActions() {
    final task = widget.task;

    switch (task.status) {
      case TaskStatus.pending:
        return Row(
          children: [
            if (task.plannedStart != null && task.plannedEnd != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onStart,
                  child: Text(_isOverdue ? 'Start now' : 'Start'),
                ),
              ),
            if (task.plannedStart == null && task.plannedEnd == null)
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  child: const Text('Complete'),
                ),
              ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onSkip,
                child: const Text('Skip'),
              ),
            ),
          ],
        );

      case TaskStatus.inProgress:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onPause,
                child: const Text('Pause'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onComplete,
                child: const Text('Complete'),
              ),
            ),
          ],
        );

      case TaskStatus.paused:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onResume,
                child: const Text('Resume'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onComplete,
                child: const Text('Complete'),
              ),
            ),
          ],
        );

      case TaskStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onReopen,
            child: const Text('Reopen'),
          ),
        );

      case TaskStatus.skipped:
        return const SizedBox.shrink();
    }
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes;

    if (totalMinutes < 1) {
      return '<1m';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      if (minutes == 0) {
        return '${hours}h';
      }

      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }
}

class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({
    required this.status,
    super.key,
  });

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TaskStatus.pending => 'Pending',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.paused => 'Paused',
      TaskStatus.completed => 'Completed',
      TaskStatus.skipped => 'Skipped',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: AppColors.surface,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}