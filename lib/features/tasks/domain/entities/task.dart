import 'package:equatable/equatable.dart';

import 'task_status.dart';
import 'task_skip_reason.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.activityId,
    this.description,
    this.dueDate,
    this.completedAt,
    this.plannedStart,
    this.plannedEnd,
    this.skippedAt,
    this.skipReason,
    this.skipNote,
  });

  final int id;
  final int? activityId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final DateTime? skippedAt;
  final TaskSkipReason? skipReason;
  final String? skipNote;

  @override
  List<Object?> get props => [
    id,
    activityId,
    title,
    description,
    status,
    dueDate,
    completedAt,
    createdAt,
    updatedAt,
    plannedStart,
    plannedEnd,
    skippedAt,
    skipReason,
    skipNote,
  ];
}
