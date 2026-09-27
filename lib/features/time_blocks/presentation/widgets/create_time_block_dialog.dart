import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/domain/entities/habit.dart';
import 'package:corelog/features/habits/domain/entities/habit_occurrence.dart';
import 'package:corelog/features/habits/presentation/providers/providers.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';
import 'package:corelog/features/time_blocks/presentation/providers/providers.dart';

Future<void> showCreateTimeBlockDialog(
  BuildContext context,
  WidgetRef ref, {
  required DateTime selectedDate,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) {
      return _CreateTimeBlockSheet(selectedDate: selectedDate);
    },
  );

  ref.invalidate(timeBlockNotifierProvider);
}

class _CreateTimeBlockSheet extends ConsumerStatefulWidget {
  const _CreateTimeBlockSheet({
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  ConsumerState<_CreateTimeBlockSheet> createState() =>
      _CreateTimeBlockSheetState();
}

class _CreateTimeBlockSheetState
    extends ConsumerState<_CreateTimeBlockSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  HabitOccurrence? _selectedOccurrence;
  Habit? _selectedHabit;
  Task? _selectedTask;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isSaving = false;

  @override
  void dispose() {
  _descriptionController.dispose();
  super.dispose();
}

  Future<List<_HabitOccurrenceOption>> _loadOccurrences() async {
    final occurrenceResult = await ref
        .read(habitOccurrenceRepositoryProvider)
        .getOccurrences();

    final occurrences = occurrenceResult.fold(
      (failure) => throw failure,
      (occurrences) => occurrences,
    );

    final selectedDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    final matchingOccurrences = occurrences.where((occurrence) {
      final occurrenceDate = DateTime(
        occurrence.scheduledDate.year,
        occurrence.scheduledDate.month,
        occurrence.scheduledDate.day,
      );

      return occurrenceDate == selectedDate &&
          occurrence.status.name == 'pending';
    }).toList();

    final options = <_HabitOccurrenceOption>[];

    for (final occurrence in matchingOccurrences) {
      final habitResult = await ref
          .read(habitRepositoryProvider)
          .getHabitById(occurrence.habitId);

      final habit = habitResult.fold(
        (failure) => throw failure,
        (habit) => habit,
      );

      if (habit == null) {
        continue;
      }

      options.add(
        _HabitOccurrenceOption(
          occurrence: occurrence,
          habit: habit,
        ),
      );
    }

    return options;
  }

  Future<List<Task>> _loadTasks() async {
    final result = await ref.read(taskRepositoryProvider).getTasks();

    return result.fold(
      (failure) => throw failure,
      (tasks) => tasks,
    );
  }

  Future<void> _selectStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (selected == null) return;

    setState(() {
      _startTime = selected;

      if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
        _endTime = TimeOfDay(
          hour: (_startTime.hour + 1) % 24,
          minute: _startTime.minute,
        );
      }
    });
  }

  Future<void> _selectEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (selected == null) return;

    setState(() {
      _endTime = selected;
    });
  }

  Future<void> _createTimeBlock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOccurrence == null) {
      _showError('Please select a habit.');
      return;
    }

    if (_timeToMinutes(_endTime) <= _timeToMinutes(_startTime)) {
      _showError('End time must be after start time.');
      return;
    }

    final plannedStart = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final plannedEnd = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final now = DateTime.now();

    final timeBlock = TimeBlock(
      id: 0,
      habitOccurrenceId: _selectedOccurrence!.id,
      taskId: _selectedTask?.id,
      description: _descriptionController.text.trim().isEmpty
    ? null
    : _descriptionController.text.trim(),
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      status: TimeBlockStatus.planned,
      createdAt: now,
      updatedAt: now,

    );

    setState(() {
      _isSaving = true;
    });

    await ref
        .read(timeBlockNotifierProvider.notifier)
        .createTimeBlock(timeBlock);

    if (!mounted) return;

    final state = ref.read(timeBlockNotifierProvider);

    if (state.hasError) {
      setState(() {
        _isSaving = false;
      });

      _showError(
        'Create failed: ${state.error}',
      );
      return;
    }

    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Time Block',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              FutureBuilder<List<_HabitOccurrenceOption>>(
                future: _loadOccurrences(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
        
                  if (snapshot.hasError) {
                    return const Text(
                      'We could not load your habits for this day.',
                    );
                  }
        
                  final options = snapshot.data ?? [];
        
                  if (options.isEmpty) {
                    return const Text(
                      'No pending habit occurrences are available for this day.',
                    );
                  }
        
                  return DropdownButtonFormField<HabitOccurrence>(
                    initialValue: _selectedOccurrence,
                    decoration: const InputDecoration(
                      labelText: 'Habit',
                    ),
                    items: options.map((option) {
                      return DropdownMenuItem<HabitOccurrence>(
                        value: option.occurrence,
                        child: Text(option.habit.name),
                      );
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (occurrence) {
                            final option = options.firstWhere(
                              (option) =>
                                  option.occurrence.id == occurrence?.id,
                            );
        
                            setState(() {
                              _selectedOccurrence = occurrence;
                              _selectedHabit = option.habit;
        
                              if (option.habit.targetTime != null) {
                                _startTime = TimeOfDay(
                                  hour: option.habit.targetTime!.hour,
                                  minute: option.habit.targetTime!.minute,
                                );
        
                                final duration =
                                    option.habit.targetDuration ??
                                        const Duration(hours: 1);
        
                                final endMinutes =
                                    _timeToMinutes(_startTime) +
                                        duration.inMinutes;
        
                                _endTime = TimeOfDay(
                                  hour: (endMinutes ~/ 60) % 24,
                                  minute: endMinutes % 60,
                                );
                              }
                            });
                          },
                    validator: (occurrence) {
                      if (occurrence == null) {
                        return 'Select a habit';
                      }
        
                      return null;
                    },
                  );
                },
              ),
              if (_selectedHabit != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _selectedHabit!.description ??
                      'Schedule time for this habit.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              FutureBuilder<List<Task>>(
                future: _loadTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
        
                  if (snapshot.hasError) {
                    return const Text(
                      'We could not load your tasks.',
                    );
                  }
        
                  final tasks = snapshot.data ?? [];
        
                  return DropdownButtonFormField<Task>(
                    initialValue: _selectedTask,
                    decoration: const InputDecoration(
                      labelText: 'Task',
                      helperText: 'Optional',
                    ),
                    items: [
                      const DropdownMenuItem<Task>(
                        value: null,
                        child: Text('No task'),
                      ),
                      ...tasks.map((task) {
                        return DropdownMenuItem<Task>(
                          value: task,
                          child: Text(
                            task.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (task) {
                            setState(() {
                              _selectedTask = task;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'Start',
                      time: _startTime,
                      onPressed: _isSaving ? null : _selectStartTime,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TimeButton(
                      label: 'End',
                      time: _endTime,
                      onPressed: _isSaving ? null : _selectEndTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What do you intend to do during this block?',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _createTimeBlock,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Time Block'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitOccurrenceOption {
  const _HabitOccurrenceOption({
    required this.occurrence,
    required this.habit,
  });

  final HabitOccurrence occurrence;
  final Habit habit;
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onPressed,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            time.format(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}