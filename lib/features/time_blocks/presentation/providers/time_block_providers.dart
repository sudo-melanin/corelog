import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/time_blocks/data/repositories/time_block_repository_impl.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';
import 'package:corelog/features/time_blocks/domain/usecases/usecases.dart';

final timeBlockRepositoryProvider =
    Provider<TimeBlockRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TimeBlockRepositoryImpl(database);
});

final startTimeBlockProvider = Provider<StartTimeBlock>((ref) {
  final repository = ref.watch(timeBlockRepositoryProvider);

  return StartTimeBlock(repository);
});

final completeTimeBlockProvider = Provider<CompleteTimeBlock>((ref) {
  final repository = ref.watch(timeBlockRepositoryProvider);

  return CompleteTimeBlock(repository);
});

final skipTimeBlockProvider = Provider<SkipTimeBlock>((ref) {
  final repository = ref.watch(timeBlockRepositoryProvider);

  return SkipTimeBlock(repository);
});