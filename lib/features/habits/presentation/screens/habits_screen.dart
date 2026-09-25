import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/presentation/providers/providers.dart';
import 'package:corelog/features/habits/presentation/widgets/widgets.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: habitsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => HabitErrorState(
              message: _errorMessage(error),
              onRetry: () {
                ref.read(habitNotifierProvider.notifier).refresh();
              },
            ),
            data: (habits) {
              if (habits.isEmpty) {
                return const HabitEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () {
                  return ref
                      .read(habitNotifierProvider.notifier)
                      .refresh();
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: habits.length,
                  separatorBuilder: (_, _) => const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  itemBuilder: (context, index) {
                    return HabitCard(habit: habits[index]);
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateHabitDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _errorMessage(Object error) {
    return 'We could not load your habits. Please try again.';
  }
}