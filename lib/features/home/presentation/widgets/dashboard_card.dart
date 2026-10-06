import 'package:flutter/material.dart';

import 'package:corelog/core/theme/theme.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: child,
    );
  }
}