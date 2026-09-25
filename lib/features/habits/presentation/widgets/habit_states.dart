import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';

class HabitEmptyState extends StatelessWidget {
  const HabitEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No habits yet'),
    );
  }
}

class HabitErrorState extends StatelessWidget {
  const HabitErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Something went wrong'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}