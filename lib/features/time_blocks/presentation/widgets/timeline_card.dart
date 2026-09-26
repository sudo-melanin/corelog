import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';
import 'package:corelog/features/time_blocks/presentation/utils/utils.dart';

class TimelineCard extends StatelessWidget {
  const TimelineCard({
    required this.item,
    required this.onTap,
    required this.onStart,
    required this.onComplete,
    required this.onSkip,
    super.key,
  });

  final TimeBlockTimelineItem item;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final timeBlock = item.timeBlock;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TimeRange(
                    start: timeBlock.plannedStart,
                    end: timeBlock.plannedEnd,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.habitName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (item.taskTitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.taskTitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                        if (timeBlock.description != null &&
                            timeBlock.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            timeBlock.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusIcon(status: timeBlock.status),
                ],
              ),
              if (timeBlock.actualStart != null ||
                  timeBlock.actualEnd != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ActualTime(
                  start: timeBlock.actualStart,
                  end: timeBlock.actualEnd,
                ),
              ],
              if (_hasActions(timeBlock.status)) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.xs),
                _ActionRow(
                  status: timeBlock.status,
                  onStart: onStart,
                  onComplete: onComplete,
                  onSkip: onSkip,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActions(TimeBlockStatus status) {
    return status == TimeBlockStatus.planned ||
        status == TimeBlockStatus.inProgress;
  }
}

class _TimeRange extends StatelessWidget {
  const _TimeRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(start),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatTime(end),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

class _ActualTime extends StatelessWidget {
  const _ActualTime({
    required this.start,
    required this.end,
  });

  final DateTime? start;
  final DateTime? end;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Actual: ${_formatTime(start)}'
      '${end == null ? '' : ' - ${_formatTime(end)}'}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '--:--';
    }

    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final TimeBlockStatus status;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _label,
      child: Icon(
        _icon,
        color: _color,
        size: 24,
      ),
    );
  }

  IconData get _icon {
    return switch (status) {
      TimeBlockStatus.planned => Icons.schedule_outlined,
      TimeBlockStatus.inProgress => Icons.play_circle_outline,
      TimeBlockStatus.completed => Icons.check_circle_outline,
      TimeBlockStatus.skipped => Icons.block_outlined,
    };
  }

  Color get _color {
    return switch (status) {
      TimeBlockStatus.planned => AppColors.textSecondary,
      TimeBlockStatus.inProgress => AppColors.primary,
      TimeBlockStatus.completed => AppColors.success,
      TimeBlockStatus.skipped => AppColors.warning,
    };
  }

  String get _label {
    return switch (status) {
      TimeBlockStatus.planned => 'Planned',
      TimeBlockStatus.inProgress => 'In progress',
      TimeBlockStatus.completed => 'Completed',
      TimeBlockStatus.skipped => 'Skipped',
    };
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.status,
    required this.onStart,
    required this.onComplete,
    required this.onSkip,
  });

  final TimeBlockStatus status;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (status == TimeBlockStatus.planned) {
      actions.add(
        Expanded(
          child: _ActionButton(
            icon: Icons.play_arrow,
            label: 'Start',
            color: AppColors.primary,
            onPressed: onStart,
          ),
        ),
      );
    }

    if (status == TimeBlockStatus.planned ||
        status == TimeBlockStatus.inProgress) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: AppSpacing.sm));
      }

      actions.add(
        Expanded(
          child: _ActionButton(
            icon: Icons.check,
            label: 'Complete',
            color: AppColors.success,
            onPressed: onComplete,
          ),
        ),
      );

      actions.add(const SizedBox(width: AppSpacing.sm));

      actions.add(
        Expanded(
          child: _ActionButton(
            icon: Icons.skip_next_outlined,
            label: 'Skip',
            color: AppColors.warning,
            onPressed: onSkip,
          ),
        ),
      );
    }

    return Row(children: actions);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      
      onPressed: onPressed,
      icon: Icon(icon, size: 17, color: color),
      label: Text(
        label,
        softWrap: false,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
      ),
        minimumSize: const Size.fromHeight(40),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}