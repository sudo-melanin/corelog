import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/activities/domain/entities/activity.dart';
import 'package:corelog/features/activities/presentation/providers/activity_providers.dart';
import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/domain/entities/task_status.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';

final createTaskActivitiesProvider =
    FutureProvider.autoDispose<List<Activity>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  final result = await repository.getActivities();

  return result.fold(
    (failure) => throw failure,
    (activities) => activities.where((activity) => activity.isActive).toList(),
  );
});

Future<void> showCreateTaskDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) {
      return const CreateTaskDialog();
    },
  );
}

class CreateTaskDialog extends ConsumerStatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  Activity? _selectedActivity;
  bool _isScheduled = false;
  DateTime? _plannedStart;
  DateTime? _plannedEnd;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectStart() async {
    final selected = await _pickDateTime(
      initialDateTime: _plannedStart ?? DateTime.now(),
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _plannedStart = selected;

      if (_plannedEnd != null && !_plannedEnd!.isAfter(selected)) {
        _plannedEnd = null;
      }
    });
  }

  Future<void> _selectEnd() async {
    final initial = _plannedEnd ??
        (_plannedStart?.add(const Duration(hours: 1)) ?? DateTime.now());

    final selected = await _pickDateTime(
      initialDateTime: initial,
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _plannedEnd = selected;
    });
  }

  Future<DateTime?> _pickDateTime({
    required DateTime initialDateTime,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return null;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _createTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showMessage('Task title is required.');
      return;
    }

    if (_isScheduled) {
      if (_plannedStart == null || _plannedEnd == null) {
        _showMessage('Please select a start and end time.');
        return;
      }

      if (!_plannedEnd!.isAfter(_plannedStart!)) {
        _showMessage('End time must be after start time.');
        return;
      }
    }

    final now = DateTime.now();

    final task = Task(
      id: 0,
      title: title,
      description: description.isEmpty ? null : description,
      activityId: _selectedActivity?.id,
      status: TaskStatus.pending,
      plannedStart: _isScheduled ? _plannedStart : null,
      plannedEnd: _isScheduled ? _plannedEnd : null,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(taskNotifierProvider.notifier).createTask(task);

    if (!mounted) {
      return;
    }

    final taskState = ref.read(taskNotifierProvider);

    if (taskState.hasError) {
      _showMessage('Could not create task.');
      return;
    }
    ref.invalidate(todayTasksProvider);
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Not selected';
    }

    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '${value.day}/${value.month}/${value.year} '
        '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(createTaskActivitiesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
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
                'Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              activitiesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text(
                  'Could not load activities.',
                ),
                data: (activities) {
                  return DropdownButtonFormField<Activity?>(
                    initialValue: _selectedActivity,
                    decoration: const InputDecoration(
                      hintText: 'No activity',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<Activity?>(
                        value: null,
                        child: Text('No activity'),
                      ),
                      ...activities.map(
                        (activity) => DropdownMenuItem<Activity?>(
                          value: activity,
                          child: Text(activity.name),
                        ),
                      ),
                    ],
                    onChanged: (activity) {
                      setState(() {
                        _selectedActivity = activity;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Schedule',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Schedule task'),
                subtitle: Text(
                  _isScheduled
                      ? 'Set when you plan to work on this task.'
                      : 'This task can be completed whenever you are ready.',
                ),
                value: _isScheduled,
                onChanged: (value) {
                  setState(() {
                    _isScheduled = value;

                    if (!value) {
                      _plannedStart = null;
                      _plannedEnd = null;
                    }
                  });
                },
              ),
              if (_isScheduled) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _selectStart,
                  icon: const Icon(Icons.schedule),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _plannedStart == null
                          ? 'Select start'
                          : 'Start: ${_formatDateTime(_plannedStart)}',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _selectEnd,
                  icon: const Icon(Icons.schedule_outlined),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _plannedEnd == null
                          ? 'Select end'
                          : 'End: ${_formatDateTime(_plannedEnd)}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _createTask,
                    child: const Text('Create'),
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