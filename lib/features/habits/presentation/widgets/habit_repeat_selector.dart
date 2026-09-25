import 'package:flutter/material.dart';

class HabitRepeatSelector extends StatelessWidget {
  const HabitRepeatSelector({
    required this.isDaily,
    required this.onChanged,
    super.key,
  });

  final bool isDaily;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: true,
          label: Text('Daily'),
          icon: Icon(Icons.calendar_today_outlined),
        ),
        ButtonSegment<bool>(
          value: false,
          label: Text('Custom'),
          icon: Icon(Icons.tune),
        ),
      ],
      selected: {isDaily},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}