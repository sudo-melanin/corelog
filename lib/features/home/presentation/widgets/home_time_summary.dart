import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/home/domain/entities/home_dashboard.dart';
import 'package:corelog/features/tasks/presentation/helpers/task_time_formatter.dart';

import 'dashboard_card.dart';

class HomeTimeSummary extends StatelessWidget {
  const HomeTimeSummary({
    required this.dashboard,
    super.key,
  });

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DashboardCard(
            child: _buildMetric(
              context,
              label: 'Active',
              value: dashboard.actualDuration,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: DashboardCard(
            child: _buildMetric(
              context,
              label: 'Planned',
              value: dashboard.plannedDuration,
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required Duration value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          TaskTimeFormatter.duration(value),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}