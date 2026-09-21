import 'package:flutter/material.dart';
import '../routing/app_router.dart';
import '../theme/theme.dart';

class CoreLogApp extends StatelessWidget {
  const CoreLogApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CoreLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
