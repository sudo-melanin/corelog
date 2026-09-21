import 'package:flutter/material.dart';

import 'core/theme/theme.dart';

void main() {
  runApp(const CoreLogApp());
}

class CoreLogApp extends StatelessWidget {
  const CoreLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoreLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CoreLogFoundationScreen(),
    );
  }
}

class CoreLogFoundationScreen extends StatelessWidget {
  const CoreLogFoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoreLog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CoreLog',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Project foundation is working.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'FOUNDATION',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Theme tokens are active',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
