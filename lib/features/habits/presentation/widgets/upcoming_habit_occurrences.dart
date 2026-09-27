import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/presentation/utils/upcoming_habit_occurrence.dart';

import 'habit_occurrence_card.dart';

class UpcomingHabitOccurrences extends StatelessWidget {
  const UpcomingHabitOccurrences({
    required this.occurrences,
    required this.onComplete,
    required this.onSkip,
    super.key,
  });

  final List<UpcomingHabitOccurrence> occurrences;
  final ValueChanged<UpcomingHabitOccurrence> onComplete;
  final ValueChanged<UpcomingHabitOccurrence> onSkip;

  @override
  Widget build(BuildContext context) {
    if (occurrences.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: occurrences.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = occurrences[index];

              return HabitOccurrenceCard(
                item: item,
                onComplete: (_) => onComplete(item),
                onSkip: (_) => onSkip(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
