import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:flutter/material.dart';


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