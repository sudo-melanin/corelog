import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/habits/presentation/screens/habits_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CoreLogShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) {
                return const HomeScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/habits',
              builder: (context, state) {
                return const HabitsScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) {
                return const TasksScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
