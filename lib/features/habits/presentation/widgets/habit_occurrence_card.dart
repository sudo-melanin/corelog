import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/presentation/utils/habit_occurrence_display_status.dart';
import 'package:corelog/features/habits/presentation/utils/upcoming_habit_occurrence.dart';

class HabitOccurrenceCard extends StatelessWidget {
  const HabitOccurrenceCard({
    required this.item,
    required this.onComplete,
    required this.onSkip,
    super.key,
  });

  final UpcomingHabitOccurrence item;
  final ValueChanged<HabitOccurrence> onComplete;
  final ValueChanged<HabitOccurrence> onSkip;

  @override
  Widget build(BuildContext context) {
    final occurrence = item.occurrence;
    final status = getHabitOccurrenceDisplayStatus(occurrence);

    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.habit.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _formatDate(occurrence.scheduledDate),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatTime(occurrence.scheduledDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatusLabel(status: status),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: () => onComplete(occurrence),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Complete'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => onSkip(occurrence),
                    icon: const Icon(Icons.skip_next_outlined, size: 18),
                    label: const Text('Skip'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final HabitOccurrenceDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      _label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: _color),
    );
  }

  String get _label {
    return switch (status) {
      HabitOccurrenceDisplayStatus.upcoming => 'Upcoming',
      HabitOccurrenceDisplayStatus.due => 'Due',
      HabitOccurrenceDisplayStatus.missed => 'Missed',
      HabitOccurrenceDisplayStatus.completed => 'Completed',
      HabitOccurrenceDisplayStatus.skipped => 'Skipped',
    };
  }

  Color get _color {
    return switch (status) {
      HabitOccurrenceDisplayStatus.upcoming => AppColors.textSecondary,
      HabitOccurrenceDisplayStatus.due => AppColors.primary,
      HabitOccurrenceDisplayStatus.missed => AppColors.error,
      HabitOccurrenceDisplayStatus.completed => AppColors.success,
      HabitOccurrenceDisplayStatus.skipped => AppColors.textSecondary,
    };
  }
}
