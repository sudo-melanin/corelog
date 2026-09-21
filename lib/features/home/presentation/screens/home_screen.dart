import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Text('Home', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
