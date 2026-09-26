import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/habits/presentation/providers/providers.dart';
import 'package:corelog/features/habits/presentation/utils/upcoming_habit_occurrence.dart';
import 'package:corelog/features/habits/presentation/widgets/widgets.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitNotifierProvider);
    final occurrencesAsync = ref.watch(habitOccurrenceNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: habitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => HabitErrorState(
              message: _errorMessage(error),
              onRetry: () {
                ref.read(habitNotifierProvider.notifier).refresh();
              },
            ),
            data: (habits) {
              final upcoming = occurrencesAsync.when(
                loading: () => <UpcomingHabitOccurrence>[],
                error: (_, _) => <UpcomingHabitOccurrence>[],
                data: (_) => ref
                    .read(habitOccurrenceNotifierProvider.notifier)
                    .upcomingOccurrences,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(habitNotifierProvider.notifier).refresh();

                  await ref
                      .read(habitOccurrenceNotifierProvider.notifier)
                      .refresh();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (upcoming.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: UpcomingHabitOccurrences(
                          occurrences: upcoming,
                          onComplete: (item) {
                            ref
                                .read(habitOccurrenceNotifierProvider.notifier)
                                .completeOccurrence(item.occurrence);
                          },
                          onSkip: (item) {
                            ref
                                .read(habitOccurrenceNotifierProvider.notifier)
                                .skipOccurrence(item.occurrence);
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xl),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: Text(
                        'Habits',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),
                    if (habits.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: HabitEmptyState(),
                      )
                    else
                      SliverList.separated(
                        itemCount: habits.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          return HabitCard(habit: habits[index]);
                        },
                      ),
                  ],
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
    return error.toString();
  }
}
