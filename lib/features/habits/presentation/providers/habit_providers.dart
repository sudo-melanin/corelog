import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';
import 'package:corelog/features/habits/data/repositories/habit_occurrence_repository_impl.dart';
import 'package:corelog/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:corelog/features/habits/domain/repositories/habit_occurrence_repository.dart';
import 'package:corelog/features/habits/domain/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return HabitRepositoryImpl(database);
});

final habitOccurrenceRepositoryProvider =
    Provider<HabitOccurrenceRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return HabitOccurrenceRepositoryImpl(database);
});