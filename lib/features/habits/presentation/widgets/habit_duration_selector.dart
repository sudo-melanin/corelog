import 'package:flutter/material.dart';

class HabitDurationSelector extends StatelessWidget {
  const HabitDurationSelector({
    required this.selectedDurationMinutes,
    required this.isCustomDuration,
    required this.onSelect,
    super.key,
  });

  final int? selectedDurationMinutes;
  final bool isCustomDuration;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DurationOption(
          label: '15 min',
          selected: !isCustomDuration && selectedDurationMinutes == 15,
          onTap: () => onSelect(15),
        ),
        _DurationOption(
          label: '30 min',
          selected: !isCustomDuration && selectedDurationMinutes == 30,
          onTap: () => onSelect(30),
        ),
        _DurationOption(
          label: '45 min',
          selected: !isCustomDuration && selectedDurationMinutes == 45,
          onTap: () => onSelect(45),
        ),
        _DurationOption(
          label: '1 hour',
          selected: !isCustomDuration && selectedDurationMinutes == 60,
          onTap: () => onSelect(60),
        ),
        _DurationOption(
          label: '1h 30m',
          selected: !isCustomDuration && selectedDurationMinutes == 90,
          onTap: () => onSelect(90),
        ),
        _DurationOption(
          label: 'Custom',
          selected: isCustomDuration,
          onTap: () => onSelect(null),
        ),
      ],
    );
  }
}

class _DurationOption extends StatelessWidget {
  const _DurationOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
