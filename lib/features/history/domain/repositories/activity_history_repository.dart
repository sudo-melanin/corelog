import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';

abstract interface class ActivityHistoryRepository {
  Future<Either<Failure, ActivityHistory>> createHistory(
    ActivityHistory history,
  );

  Future<Either<Failure, ActivityHistory?>> getHistoryById(int id);

  Future<Either<Failure, List<ActivityHistory>>> getHistory();

  Future<Either<Failure, List<ActivityHistory>>> getHistoryByActivity(
    int activityId,
  );

  Future<Either<Failure, List<ActivityHistory>>> getHistoryByTask(
    int taskId,
  );
}