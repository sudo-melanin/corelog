import 'package:equatable/equatable.dart';

import 'time_block_status.dart';

class TimeBlock extends Equatable {
  const TimeBlock({
    required this.id,
    required this.habitOccurrenceId,
    required this.plannedStart,
    required this.plannedEnd,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.taskId,
    this.actualStart,
    this.actualEnd,
    this.description,
  });

  final int id;
  final int habitOccurrenceId;
  final int? taskId;
  final DateTime plannedStart;
  final DateTime plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final TimeBlockStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    habitOccurrenceId,
    taskId,
    plannedStart,
    plannedEnd,
    actualStart,
    actualEnd,
    status,
    createdAt,
    updatedAt,
    description,
  ];
}
