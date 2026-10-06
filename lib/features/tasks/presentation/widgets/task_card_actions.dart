import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_timing.dart';

class TaskCardActions extends StatelessWidget {
  const TaskCardActions({
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
  Widget build(BuildContext context) {
    switch (task.status) {
      case TaskStatus.pending:
        return _buildPendingActions();

      case TaskStatus.inProgress:
        return _buildInProgressActions();

      case TaskStatus.paused:
        return _buildPausedActions();

      case TaskStatus.completed:
        return _buildCompletedActions();

      case TaskStatus.skipped:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPendingActions() {
    final isScheduled =
        task.plannedStart != null && task.plannedEnd != null;

    final isOverdue = TaskTiming.isOverdue(
      task,
      now: DateTime.now(),
    );

    return Row(
      children: [
        if (isScheduled)
          Expanded(
            child: OutlinedButton(
              onPressed: onStart,
              child: Text(
                isOverdue ? 'Start now' : 'Start',
              ),
            ),
          )
        else
          Expanded(
            child: ElevatedButton(
              onPressed: onComplete,
              child: const Text('Complete'),
            ),
          ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton(
            onPressed: onSkip,
            child: const Text('Skip'),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPause,
            child: const Text('Pause'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: onComplete,
            child: const Text('Complete'),
          ),
        ),
      ],
    );
  }

  Widget _buildPausedActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onResume,
            child: const Text('Resume'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: onComplete,
            child: const Text('Complete'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedActions() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onReopen,
        child: const Text('Reopen'),
      ),
    );
  }
}