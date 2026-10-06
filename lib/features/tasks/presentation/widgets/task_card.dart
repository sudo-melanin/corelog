import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_timing.dart';
import 'package:corelog/features/tasks/presentation/widgets/task_card_actions.dart';
import 'package:corelog/features/tasks/presentation/widgets/task_card_timing.dart';
import 'package:corelog/features/tasks/presentation/widgets/task_status_chip.dart';

class TaskCard extends StatelessWidget {
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

  Color _borderColor() {
    final now = DateTime.now();

    if (TaskTiming.isOverdue(task, now: now)) {
      return AppColors.error;
    }

    switch (task.status) {
      case TaskStatus.inProgress:
        return AppColors.success;

      case TaskStatus.paused:
        return AppColors.warning;

      case TaskStatus.pending:
        final isUnscheduled =
            task.plannedStart == null && task.plannedEnd == null;

        if (isUnscheduled) {
          return AppColors.divider;
        }

        if (task.plannedStart != null &&
            task.plannedStart!.isAfter(now)) {
          return AppColors.warning;
        }

        return AppColors.divider;

      case TaskStatus.completed:
      case TaskStatus.skipped:
        return AppColors.divider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _borderColor(),
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
          TaskCardTiming(task: task),
          const SizedBox(height: AppSpacing.md),
          TaskCardActions(
            task: task,
            onStart: onStart,
            onPause: onPause,
            onResume: onResume,
            onComplete: onComplete,
            onSkip: onSkip,
            onReopen: onReopen,
          ),
        ],
      ),
    );
  }
}