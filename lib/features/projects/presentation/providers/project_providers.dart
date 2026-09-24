import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/projects/data/repositories/project_repository_impl.dart';
import 'package:corelog/features/projects/domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return ProjectRepositoryImpl(database);
});