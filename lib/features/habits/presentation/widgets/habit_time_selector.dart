import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/presentation/formatters/habit_formatters.dart';

class HabitTimeSelector extends StatelessWidget {
  const HabitTimeSelector({
    required this.targetTime,
    required this.onSelect,
    super.key,
  });

  final TimeOfDay? targetTime;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onSelect,
        icon: const Icon(Icons.schedule_outlined),
        label: Text(formatHabitTime(context, targetTime)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
      ),
    );
  }
}
