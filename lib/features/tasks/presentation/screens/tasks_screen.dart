import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Text('Tasks', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
