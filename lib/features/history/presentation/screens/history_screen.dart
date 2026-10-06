import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';
import 'package:corelog/features/history/presentation/providers/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, _) => const Center(
          child: Text('Unable to load history.'),
        ),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   const Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No history yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Completed and skipped tasks will appear here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final sortedHistory = [...history]
            ..sort(
              (a, b) => b.occurredAt.compareTo(a.occurredAt),
            );

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: sortedHistory.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _HistoryCard(
                history: sortedHistory[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.history,
  });

  final ActivityHistory history;

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        history.outcome == HistoryOutcome.completed;

    final isScheduled =
        history.plannedStart != null &&
        history.plannedEnd != null;

    final accentColor = isCompleted
        ? AppColors.success
        : AppColors.warning;

    final outcomeLabel = isCompleted ? 'Completed' : 'Skipped';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_rounded
                      : Icons.skip_next_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.taskTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$outcomeLabel · '
                      '${_formatDateTime(history.occurredAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _HistorySchedule(
            history: history,
            isScheduled: isScheduled,
          ),
          if (isCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            _HistoryDuration(
              history: history,
              isScheduled: isScheduled,
            ),
          ],
          if (!isCompleted && history.skipReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Reason',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatSkipReason(history.skipReason.toString()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (!isCompleted &&
              history.skipNote != null &&
              history.skipNote!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              history.skipNote!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '$hour:$minute $period';
  }

  String _formatSkipReason(String value) {
    final name = value.split('.').last;

    final formatted = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );

    return formatted.trim().replaceFirst(
          formatted.trim()[0],
          formatted.trim()[0].toUpperCase(),
        );
  }
}

class _HistorySchedule extends StatelessWidget {
  const _HistorySchedule({
    required this.history,
    required this.isScheduled,
  });

  final ActivityHistory history;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    if (!isScheduled) {
      return Row(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Unscheduled',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(
          Icons.schedule_rounded,
          size: 16,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${_formatTime(history.plannedStart!)} → '
          '${_formatTime(history.plannedEnd!)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

class _HistoryDuration extends StatelessWidget {
  const _HistoryDuration({
    required this.history,
    required this.isScheduled,
  });

  final ActivityHistory history;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    final actual = _formatDuration(history.actualDuration);

    if (!isScheduled) {
      return Row(
        children: [
          Text(
            'Actual',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            actual,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    final plannedDuration = history.plannedEnd!.difference(
      history.plannedStart!,
    );

    return Row(
      children: [
        Text(
          'Planned ${_formatDuration(plannedDuration)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          'Actual $actual',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return '—';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    }

    if (hours > 0) {
      return '${hours}h';
    }

    return '${minutes}m';
  }
}