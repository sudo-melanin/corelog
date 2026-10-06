import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';

class TodayTaskSections extends StatelessWidget {
  const TodayTaskSections({
    required this.nowTasks,
    required this.overdueTasks,
    required this.upNextTasks,
    required this.unscheduledTasks,
    required this.taskBuilder,
    required this.currentDate,
    super.key,
  });

  final List<Task> nowTasks;
  final List<Task> overdueTasks;
  final List<Task> upNextTasks;
  final List<Task> unscheduledTasks;
  final DateTime currentDate;

  final Widget Function(Task task) taskBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(currentDate),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (nowTasks.isNotEmpty)
          _buildSection(context, title: 'Now', tasks: nowTasks),
        if (overdueTasks.isNotEmpty)
          _buildSection(context, title: 'Overdue', tasks: overdueTasks),
        if (upNextTasks.isNotEmpty)
          _buildSection(context, title: 'Up Next', tasks: upNextTasks),
        if (unscheduledTasks.isNotEmpty)
          _buildSection(context, title: 'Unscheduled', tasks: unscheduledTasks),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Task> tasks,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: taskBuilder(task),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
