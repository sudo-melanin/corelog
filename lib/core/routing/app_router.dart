import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const _RouterPlaceholderScreen();
      },
    ),
  ],
);

class _RouterPlaceholderScreen extends StatelessWidget {
  const _RouterPlaceholderScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('CoreLog')));
  }
}
