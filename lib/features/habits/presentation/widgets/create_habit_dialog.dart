import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/presentation/providers/providers.dart';
import 'habit_duration_selector.dart';
import 'habit_repeat_selector.dart';
import 'habit_time_selector.dart';
import 'habit_weekday_selector.dart';

Future<void> showCreateHabitDialog(
  BuildContext context,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: AppColors.surface,
    builder: (_) {
      return const CreateHabitDialog();
    },
  );
}

class CreateHabitDialog extends ConsumerStatefulWidget {
  const CreateHabitDialog({super.key});

  @override
  ConsumerState<CreateHabitDialog> createState() =>
      _CreateHabitDialogState();
}

class _CreateHabitDialogState
    extends ConsumerState<CreateHabitDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customDurationController;

  bool _isDaily = true;
  int _weekdayMask = 127;
  TimeOfDay? _targetTime;
  int? _selectedDurationMinutes = 30;
  bool _isCustomDuration = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _customDurationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customDurationController.dispose();

    super.dispose();
  }

  Future<void> _selectTargetTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _targetTime ??
          const TimeOfDay(
            hour: 7,
            minute: 0,
          ),
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      _targetTime = selectedTime;
    });
  }

  void _setRepeatMode(bool isDaily) {
    setState(() {
      _isDaily = isDaily;

      if (isDaily) {
        _weekdayMask = 127;
      }
    });
  }

  void _toggleWeekday(int weekday) {
    if (_isDaily) {
      return;
    }

    final bit = 1 << (weekday - 1);

    setState(() {
      if ((_weekdayMask & bit) != 0) {
        _weekdayMask &= ~bit;
      } else {
        _weekdayMask |= bit;
      }
    });
  }

  void _selectDuration(int? minutes) {
    setState(() {
      _isCustomDuration = minutes == null;
      _selectedDurationMinutes = minutes;

      if (minutes != null) {
        _customDurationController.clear();
      }
    });
  }

  int? _getDurationMinutes() {
    if (!_isCustomDuration) {
      return _selectedDurationMinutes;
    }

    final value = int.tryParse(
      _customDurationController.text.trim(),
    );

    if (value == null || value <= 0) {
      return null;
    }

    return value;
  }

  Future<void> _createHabit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final durationMinutes = _getDurationMinutes();

    if (name.isEmpty) {
      _showValidationMessage('Enter a habit name.');
      return;
    }

    if (_weekdayMask == 0) {
      _showValidationMessage(
        'Select at least one day for this habit.',
      );
      return;
    }

    if (durationMinutes == null) {
      _showValidationMessage(
        'Enter a valid duration in minutes.',
      );
      return;
    }

    final now = DateTime.now();

    final targetTime = _targetTime == null
        ? null
        : DateTime(
            now.year,
            now.month,
            now.day,
            _targetTime!.hour,
            _targetTime!.minute,
          );

    final habit = Habit(
      id: 0,
      name: name,
      description: description.isEmpty ? null : description,
      weekdayMask: _weekdayMask,
      targetTime: targetTime,
      targetDuration: Duration(
        minutes: durationMinutes,
      ),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    setState(() {
      _isSaving = true;
    });

    await ref
        .read(habitNotifierProvider.notifier)
        .createHabit(habit);

    if (!mounted) {
      return;
    }

    final habitState = ref.read(habitNotifierProvider);

    if (habitState.hasError) {
      setState(() {
        _isSaving = false;
      });

      _showValidationMessage(
        'We could not create the habit. Please try again.',
      );
      return;
    }

    Navigator.of(context).pop();
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             const _SheetHandle(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'New Habit',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Repeat',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              HabitRepeatSelector(
                isDaily: _isDaily,
                onChanged: _setRepeatMode,
              ),
              if (!_isDaily) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                HabitWeekdaySelector(
                  weekdayMask: _weekdayMask,
                  onToggle: _toggleWeekday,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Target time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              HabitTimeSelector(
                targetTime: _targetTime,
                onSelect: _selectTargetTime,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Duration',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              HabitDurationSelector(
                selectedDurationMinutes: _selectedDurationMinutes,
                isCustomDuration: _isCustomDuration,
                onSelect: _selectDuration,
              ),
              if (_isCustomDuration) ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _customDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration in minutes',
                    hintText: 'e.g. 120',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _createHabit,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Create'),
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
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(
            AppRadius.sm,
          ),
        ),
      ),
    );
  }
}