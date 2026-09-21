import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const CoreLogShell(
          child: Center(
            child: Text('CoreLog'),
          )
        );
      },
    ),
  ],
);
