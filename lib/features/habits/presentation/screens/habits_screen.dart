import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Text(
          'Habits',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
