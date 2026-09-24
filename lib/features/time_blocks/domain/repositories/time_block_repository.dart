import 'package:fpdart/fpdart.dart' ;

import 'package:corelog/core/error/error.dart' ;
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';

abstract interface class TimeBlockRepository {
  Future<Either<Failure, TimeBlock>> createTimeBlock(
    TimeBlock timeBlock,
  );

  Future<Either<Failure, TimeBlock?>> getTimeBlockById(
    int id,
  );

  Future<Either<Failure, List<TimeBlock>>> getTimeBlocks();

  Future<Either<Failure, List<TimeBlock>>> getTimeBlocksByProject(
    int projectId,
  );

  Future<Either<Failure, List<TimeBlock>>> getTimeBlocksByTask(
    int taskId,
  );

  Future<Either<Failure, TimeBlock>> updateTimeBlock(
    TimeBlock timeBlock,
  );

  Future<Either<Failure, Unit>> deleteTimeBlock(
    int id,
  );
}