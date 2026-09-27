import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/time_blocks/presentation/utils/utils.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';

Future<void> showTimeBlockDetailsSheet(
  BuildContext context, {
  required TimeBlockTimelineItem item,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TimeBlockDetailsSheet(item: item),
  );
}

class _TimeBlockDetailsSheet extends StatelessWidget {
  const _TimeBlockDetailsSheet({
    required this.item,
  });

  final TimeBlockTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final timeBlock = item.timeBlock;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Time Block Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Habit',
            value: item.habitName,
          ),
          if (item.taskTitle != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              label: 'Task',
              value: item.taskTitle!,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: 'Planned',
            value:
                '${_formatTime(timeBlock.plannedStart)} - '
                '${_formatTime(timeBlock.plannedEnd)}',
          ),
          if (timeBlock.actualStart != null ||
              timeBlock.actualEnd != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              label: 'Actual',
              value:
                  '${_formatTime(timeBlock.actualStart)}'
                  '${timeBlock.actualEnd == null ? '' : ' - ${_formatTime(timeBlock.actualEnd)}'}',
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            label: 'Status',
            value: _statusLabel(timeBlock.status),
          ),
          if (timeBlock.description != null &&
              timeBlock.description!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Description',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              timeBlock.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
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

  String _statusLabel(TimeBlockStatus status) {
    return switch (status.toString().split('.').last) {
      'planned' => 'Planned',
      'inProgress' => 'In progress',
      'completed' => 'Completed',
      'skipped' => 'Skipped',
      _ => 'Unknown',
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}