import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:corelog/features/activities/domain/repositories/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return ActivityRepositoryImpl(database);
});