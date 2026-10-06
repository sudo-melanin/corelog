import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/features/history/domain/usecases/usecases.dart';
import 'package:corelog/features/tasks/presentation/providers/providers.dart';

final getHistoryProvider = Provider<GetHistory>((ref) {
  final repository = ref.watch(
    activityHistoryRepositoryProvider,
  );

  return GetHistory(repository);
});

final historyProvider =
    FutureProvider.autoDispose((ref) async {
  final getHistory = ref.watch(getHistoryProvider);

  final result = await getHistory();

  return result.fold(
    (failure) => throw failure,
    (history) => history,
  );
});