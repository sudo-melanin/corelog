import 'package:fpdart/fpdart.dart';

import 'package:corelog/core/error/error.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block_status.dart';
import 'package:corelog/features/time_blocks/domain/repositories/time_block_repository.dart';

class StartTimeBlock {
  const StartTimeBlock(this._repository);

  final TimeBlockRepository _repository;

  Future<Either<Failure, TimeBlock>> call(
    TimeBlock timeBlock,
  ) {
    final now = DateTime.now();

    final startedTimeBlock = TimeBlock(
      id: timeBlock.id,
      projectId: timeBlock.projectId,
      taskId: timeBlock.taskId,
      plannedStart: timeBlock.plannedStart,
      plannedEnd: timeBlock.plannedEnd,
      actualStart: now,
      actualEnd: timeBlock.actualEnd,
      status: TimeBlockStatus.inProgress,
      createdAt: timeBlock.createdAt,
      updatedAt: now,
    );

    return _repository.updateTimeBlock(startedTimeBlock);
  }
}