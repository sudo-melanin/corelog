import 'package:equatable/equatable.dart';

class TaskExecutionSession extends Equatable {
  const TaskExecutionSession({
    required this.id,
    required this.taskId,
    required this.startedAt,
    this.endedAt,
  });

  final int id;
  final int taskId;
  final DateTime startedAt;
  final DateTime? endedAt;

  TaskExecutionSession copyWith({
  int? id,
  int? taskId,
  DateTime? startedAt,
  DateTime? endedAt,
}) {
  return TaskExecutionSession(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
  );
}

  @override
  List<Object?> get props => [
        id,
        taskId,
        startedAt,
        endedAt,
      ];
}