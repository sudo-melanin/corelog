import 'package:equatable/equatable.dart';

import 'time_block_status.dart';

class TimeBlock extends Equatable {
  const TimeBlock({
    required this.id,
    required this.projectId,
    required this.plannedStart,
    required this.plannedEnd,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.taskId,
    this.actualStart,
    this.actualEnd,
  });

  final int id;
  final int projectId;
  final int? taskId;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final TimeBlockStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        taskId,
        plannedStart,
        plannedEnd,
        actualStart,
        actualEnd,
        status,
        createdAt,
        updatedAt,
      ];
}