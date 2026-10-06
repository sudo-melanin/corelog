import 'package:go_router/go_router.dart';

import '../widgets/app_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/habits/presentation/screens/habits_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/screens/task_details_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';

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
              routes: [
                GoRoute(
                  path: 'details',
                  builder: (context, state) {
                    final task = state.extra as Task;

                    return TaskDetailsScreen(task: task);
                  }
                )
              ]
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/history',
      builder: (context, state) {
        return const HistoryScreen();
      },
    ),
  ],
);
