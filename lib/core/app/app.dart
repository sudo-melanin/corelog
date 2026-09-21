import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CoreLogApp extends StatelessWidget {
  const CoreLogApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoreLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _ApplicationPlaceholder(),
    );
  }
}

class _ApplicationPlaceholder extends StatelessWidget {
  const _ApplicationPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CoreLog')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            'Application foundation is working.',
            style: Theme.of(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
