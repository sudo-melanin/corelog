import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/metrics/presentation/providers/providers.dart';

class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final metricsAsync = ref.watch(
      productivityMetricsProvider(
        (
          start: start,
          end: end,
        ),
      ),
    );

    final activitiesAsync = ref.watch(metricsActivitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity'),
      ),
      body: metricsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Unable to load productivity metrics.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (metrics) {
          final activities = activitiesAsync.valueOrNull ?? [];

          final activityNames = {
            for (final activity in activities)
              activity.id: activity.name,
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              _CompletionSummary(
                completionRate: metrics.completionRate,
                completedCount: metrics.completedTaskCount,
                skippedCount: metrics.skippedTaskCount,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(title: 'Time'),
              const SizedBox(height: AppSpacing.sm),
              _TimeSummary(
                plannedDuration: metrics.plannedDuration,
                actualDuration: metrics.actualDuration,
              ),
              if (metrics.activityBreakdown.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle(title: 'Activity Time'),
                const SizedBox(height: AppSpacing.sm),
                _MetricsSection(
                  children: [
                    ...metrics.activityBreakdown.entries.map(
                      (entry) => _ActivityMetricTile(
                        name: activityNames[entry.key] ?? 'Unknown activity',
                        duration: entry.value,
                      ),
                    ),
                  ],
                ),
              ],
              if (metrics.skipReasonBreakdown.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle(title: 'Skip Reasons'),
                const SizedBox(height: AppSpacing.sm),
                _MetricsSection(
                  children: [
                    ...metrics.skipReasonBreakdown.entries.map(
                      (entry) => _SkipReasonTile(
                        reason: _formatSkipReason(entry.key),
                        count: entry.value,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CompletionSummary extends StatelessWidget {
  const _CompletionSummary({
    required this.completionRate,
    required this.completedCount,
    required this.skippedCount,
  });

  final double completionRate;
  final int completedCount;
  final int skippedCount;

  @override
  Widget build(BuildContext context) {
    final percentage = (completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TODAY',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Completion rate',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _CountLabel(
                  label: 'Completed',
                  value: completedCount,
                  valueColor: AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.divider,
              ),
              Expanded(
                child: _CountLabel(
                  label: 'Skipped',
                  value: skippedCount,
                  valueColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  const _CountLabel({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final int value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TimeSummary extends StatelessWidget {
  const _TimeSummary({
    required this.plannedDuration,
    required this.actualDuration,
  });

  final Duration plannedDuration;
  final Duration actualDuration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeCard(
            label: 'Planned',
            duration: plannedDuration,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TimeCard(
            label: 'Actual',
            duration: actualDuration,
            accentColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.duration,
    this.accentColor,
  });

  final String label;
  final Duration duration;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatDuration(duration),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _ActivityMetricTile extends StatelessWidget {
  const _ActivityMetricTile({
    required this.name,
    required this.duration,
  });

  final String name;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _formatDuration(duration),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SkipReasonTile extends StatelessWidget {
  const _SkipReasonTile({
    required this.reason,
    required this.count,
  });

  final String reason;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatSkipReason(TaskSkipReason reason) {
  switch (reason) {
    case TaskSkipReason.notEnoughTime:
      return 'Not enough time';
    case TaskSkipReason.higherPriorityCameUp:
      return 'Higher priority came up';
    case TaskSkipReason.lostFocus:
      return 'Lost focus';
    case TaskSkipReason.notFeelingWell:
      return 'Not feeling well';
    case TaskSkipReason.noLongerRelevant:
      return 'No longer relevant';
    case TaskSkipReason.other:
      return 'Other';
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0) {
    return '${minutes}m';
  }

  if (minutes == 0) {
    return '${hours}h';
  }

  return '${hours}h ${minutes}m';
}