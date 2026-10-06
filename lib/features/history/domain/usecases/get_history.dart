import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/repositories/activity_history_repository.dart';

class GetHistory {
  const GetHistory(this._repository);

  final ActivityHistoryRepository _repository;

  Future<Either<Failure, List<ActivityHistory>>> call() {
    return _repository.getHistory();
  }
}