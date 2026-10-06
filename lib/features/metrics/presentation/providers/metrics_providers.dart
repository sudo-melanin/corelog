import 'package:corelog/features/activities/presentation/providers/activity_providers.dart';
import 'package:corelog/features/metrics/domain/entities/productivity_metrics.dart';
import 'package:corelog/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:corelog/features/metrics/domain/usecases/usecases.dart';

final getProductivityMetricsProvider =
    Provider<GetProductivityMetrics>((ref) {
  return GetProductivityMetrics(
    ref.watch(activityHistoryRepositoryProvider),
  );
});

final productivityMetricsProvider = FutureProvider.autoDispose
    .family<ProductivityMetrics, ({DateTime start, DateTime end})>(
  (ref, period) async {
    final getMetrics =
        ref.watch(getProductivityMetricsProvider);

    final result = await getMetrics(
      startDate: period.start,
      endDate: period.end,
    );

    return result.fold(
      (failure) => throw failure,
      (metrics) => metrics,
    );
  },
);

final metricsActivitiesProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(activityRepositoryProvider);

  final result = await repository.getActivities();

  return result.fold(
    (failure) => throw failure,
    (activities) => activities,
  );
});