import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    super.key,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          // Task details will be connected here.
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              if (task.description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TaskStatusChip(status: task.status),
            ],
          ),
        ),
      ),
    );
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
    return Chip(
      label: Text(_statusLabel),
      visualDensity: VisualDensity.compact,
      labelStyle: Theme.of(context).textTheme.labelMedium,
    );
  }

  String get _statusLabel {
    return switch (status) {
      TaskStatus.pending => 'Pending',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.completed => 'Completed',
      TaskStatus.cancelled => 'Cancelled',
    };
  }
}