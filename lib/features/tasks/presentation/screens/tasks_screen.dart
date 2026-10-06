import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';
import 'package:corelog/features/tasks/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: tasksAsync.when(
            loading: () => const TaskLoadingState(),
            error: (error, _) => TaskErrorState(
              message: _errorMessage(error),
              onRetry: () {
                ref.invalidate(todayTasksProvider);
              },
            ),
            data: (tasks) {
              final groups = TodayTaskGroups.fromTasks(
                tasks,
                currentTime: DateTime.now(),
              );
              if (tasks.isEmpty) {
                return const TaskEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(todayTasksProvider);
                  await ref.read(todayTasksProvider.future);
                },
                child: TodayTaskSections(
                  nowTasks: groups.now,
                  overdueTasks: groups.overdue,
                  upNextTasks: groups.upNext,
                  unscheduledTasks: groups.unscheduled,
                  currentDate: DateTime.now(),
                  taskBuilder: (task) {
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/tasks/details',
                          extra: task,
                        );
                      },
                      child: TaskCard(
                        task: task,
                        onComplete: () => TaskCardActionHandlers.complete(
                          context: context,
                          ref: ref,
                          task: task,
                        ),
                        onReopen: () => TaskCardActionHandlers.reopen(
                          context: context,
                          ref: ref,
                          task: task,
                        ),
                        onStart: () => TaskCardActionHandlers.start(
                          context: context,
                          ref: ref,
                          task: task,
                        ),
                        onPause: () => TaskCardActionHandlers.pause(
                          context: context,
                          ref: ref,
                          task: task,
                        ),
                        onResume: () => TaskCardActionHandlers.resume(
                          context: context,
                          ref: ref,
                          task: task,
                        ),
                        onSkip: () => TaskCardActionHandlers.skip(
                          context: context,
                          ref: ref,
                          task: task,
                        ),
                      ),
                    );
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
