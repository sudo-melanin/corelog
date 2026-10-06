import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/features/activities/presentation/providers/providers.dart';
import 'package:corelog/features/home/domain/usecases/usecases.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';

final getHomeDashboardProvider = Provider<GetHomeDashboard>((ref) {
  return GetHomeDashboard(
    taskRepository: ref.watch(taskRepositoryProvider),
    sessionRepository: ref.watch(
      taskExecutionSessionRepositoryProvider,
    ),
    activityRepository: ref.watch(activityRepositoryProvider),
  );
});

final homeDashboardProvider =
    FutureProvider.autoDispose((ref) async {
  final getHomeDashboard = ref.watch(getHomeDashboardProvider);

  final result = await getHomeDashboard(DateTime.now());

  return result.fold(
    (failure) => throw failure,
    (dashboard) => dashboard,
  );
});