import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/activities/domain/entities/activity.dart';

abstract interface class ActivityRepository {
  Future<Either<Failure, Activity>> createActivity(Activity activity);

  Future<Either<Failure, Activity?>> getActivityById(int id);

  Future<Either<Failure, List<Activity>>> getActivities();

  Future<Either<Failure, Activity>> updateActivity(Activity activity);

  Future<Either<Failure, Unit>> deleteActivity(int id);
}