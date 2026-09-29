import 'package:flutter/material.dart';

import 'package:corelog/features/tasks/domain/entities/task_skip_reason.dart';

class SkipTaskDialogResult {
  const SkipTaskDialogResult({
    required this.reason,
    this.note,
  });

  final TaskSkipReason reason;
  final String? note;
}

Future<SkipTaskDialogResult?> showSkipTaskDialog(
  BuildContext context,
) {
  return showDialog<SkipTaskDialogResult>(
    context: context,
    builder: (_) => const _SkipTaskDialog(),
  );
}

class _SkipTaskDialog extends StatefulWidget {
  const _SkipTaskDialog();

  @override
  State<_SkipTaskDialog> createState() => _SkipTaskDialogState();
}

class _SkipTaskDialogState extends State<_SkipTaskDialog> {
  TaskSkipReason? _selectedReason;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Skip task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you skipping this task?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            RadioGroup<TaskSkipReason>(
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              child: Column(
                children: [
                  ...TaskSkipReason.values.map(
                    (reason) => RadioListTile<TaskSkipReason>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_reasonLabel(reason)),
                      value: reason,
                    ),
                  ),
                ],
              ),
            ),
                        const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a note if useful...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  final note = _noteController.text.trim();

                  Navigator.of(context).pop(
                    SkipTaskDialogResult(
                      reason: _selectedReason!,
                      note: note.isEmpty ? null : note,
                    ),
                  );
                },
          child: const Text('Skip task'),
        ),
      ],
    );
  }

  String _reasonLabel(TaskSkipReason reason) {
    return switch (reason) {
      TaskSkipReason.notEnoughTime => 'Not enough time',
      TaskSkipReason.higherPriorityCameUp => 'Higher priority came up',
      TaskSkipReason.lostFocus => 'Lost focus',
      TaskSkipReason.notFeelingWell => 'Not feeling well',
      TaskSkipReason.noLongerRelevant => 'No longer relevant',
      TaskSkipReason.other => 'Other',
    };
  }
}