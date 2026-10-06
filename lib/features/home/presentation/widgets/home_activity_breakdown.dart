import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/home/domain/entities/home_dashboard.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_time_formatter.dart';

import 'dashboard_card.dart';

class HomeActivityBreakdown extends StatelessWidget {
  const HomeActivityBreakdown({
    required this.dashboard,
    super.key,
  });

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final activities = dashboard.activityBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final visibleActivities = activities.take(5).toList();
    final remainingCount = activities.length - visibleActivities.length;

    final totalDuration = activities.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.value,
    );

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ...visibleActivities.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.md,
              ),
              child: _buildActivity(
                context,
                name: entry.key,
                duration: entry.value,
                totalDuration: totalDuration,
              ),
            ),
          ),
          if (remainingCount > 0)
            Text(
              '+ $remainingCount more',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildActivity(
    BuildContext context, {
    required String name,
    required Duration duration,
    required Duration totalDuration,
  }) {
    final totalMinutes = totalDuration.inMinutes;
    final activityMinutes = duration.inMinutes;

    final share = totalMinutes == 0
        ? 0.0
        : activityMinutes / totalMinutes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              TaskTimeFormatter.duration(duration),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: share.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}