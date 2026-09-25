import 'package:flutter/material.dart';

class HabitWeekdaySelector extends StatelessWidget {
  const HabitWeekdaySelector({
    required this.weekdayMask,
    required this.onToggle,
    super.key,
  });

  final int weekdayMask;
  final ValueChanged<int> onToggle;

  static const _days = [
    ('M', 1),
    ('T', 2),
    ('W', 3),
    ('T', 4),
    ('F', 5),
    ('S', 6),
    ('S', 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days.map((day) {
        final label = day.$1;
        final weekday = day.$2;
        final bit = 1 << (weekday - 1);
        final selected = (weekdayMask & bit) != 0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onToggle(weekday),
              showCheckmark: false,
            ),
          ),
        );
      }).toList(),
    );
  }
}