import 'package:equatable/equatable.dart';

import 'task_status.dart';

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.projectId,
    this.description,
    this.dueDate,
    this.completedAt,
  });

  final int id;
  final int? projectId;
  final String title;
  final String? description;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        status,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
      ];
}