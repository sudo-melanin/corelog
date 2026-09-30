import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/features/tasks/domain/entities/task.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/tasks/presentation/widgets/skip_task_dialog.dart';

class TaskCardActionHandlers {
  const TaskCardActionHandlers._();

  static Future<void> complete({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    await _runMutation(
      context: context,
      ref: ref,
      action: () => ref
          .read(taskNotifierProvider.notifier)
          .completeTask(task),
      successMessage: 'Task completed.',
      failureMessage: 'Could not complete task.',
    );
  }

  static Future<void> start({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    await _runMutation(
      context: context,
      ref: ref,
      action: () => ref
          .read(taskNotifierProvider.notifier)
          .startTask(task),
      successMessage: 'Task started.',
      failureMessage: 'Could not start task.',
    );
  }

  static Future<void> pause({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    await _runMutation(
      context: context,
      ref: ref,
      action: () => ref
          .read(taskNotifierProvider.notifier)
          .pauseTask(task),
      successMessage: 'Task paused.',
      failureMessage: 'Could not pause task.',
    );
  }

  static Future<void> resume({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    await _runMutation(
      context: context,
      ref: ref,
      action: () => ref
          .read(taskNotifierProvider.notifier)
          .resumeTask(task),
      successMessage: 'Task resumed.',
      failureMessage: 'Could not resume task.',
    );
  }

  static Future<void> skip({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    final result = await showSkipTaskDialog(context);

    if (result == null || !context.mounted) {
      return;
    }

    await _runMutation(
      context: context,
      ref: ref,
      action: () => ref
          .read(taskNotifierProvider.notifier)
          .skipTask(
            task: task,
            reason: result.reason,
            note: result.note,
          ),
      successMessage: 'Task skipped.',
      failureMessage: 'Could not skip task.',
    );
  }

  static Future<void> reopen({
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
  }) async {
    final success = await ref
        .read(taskNotifierProvider.notifier)
        .reopenTask(task);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Task reopened.' : 'Could not reopen task.',
          ),
        ),
      );

    if (success) {
      ref.invalidate(todayTasksProvider);
    }
  }

  static Future<void> _runMutation({
    required BuildContext context,
    required WidgetRef ref,
    required Future<bool> Function() action,
    required String successMessage,
    required String failureMessage,
  }) async {
    final success = await action();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success ? successMessage : failureMessage,
          ),
        ),
      );

    if (success) {
      ref.invalidate(todayTasksProvider);
    }
  }
}