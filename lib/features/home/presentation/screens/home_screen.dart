import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/home/presentation/providers/providers.dart';
import 'package:corelog/features/home/presentation/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/history');
            },
            icon: const Icon(Icons.history_rounded),),
          IconButton(
            onPressed: () {
              context.push('/metrics');
            },
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'Productivity',
          ),
        ]
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: dashboardAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (_, _) => _buildError(context, ref),
            data: (dashboard) => ListView(
              children: [
                const HomeDateHeader(),
                const SizedBox(height: AppSpacing.lg),
                HomeTaskProgress(dashboard: dashboard),
                const SizedBox(height: AppSpacing.md),
                HomeTimeSummary(dashboard: dashboard),
                if (dashboard.activityBreakdown.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  HomeActivityBreakdown(dashboard: dashboard),
                ],
                if (dashboard.recentCompletedTasks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  HomeRecentTasks(dashboard: dashboard),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'We could not load your dashboard.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {
              ref.invalidate(homeDashboardProvider);
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}