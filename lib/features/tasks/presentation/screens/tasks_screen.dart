import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/tasks/presentation/widgets/widgets.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: tasksAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => TaskErrorState(
              message: _errorMessage(error),
              onRetry: () {
                ref.read(taskNotifierProvider.notifier).refresh();
              },
            ),
            data: (tasks) {
              if (tasks.isEmpty) {
                return const TaskEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () {
                  return ref
                      .read(taskNotifierProvider.notifier)
                      .refresh();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateTaskDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _errorMessage(Object error) {
    return 'We could not load your tasks. Please try again.';
  }
}