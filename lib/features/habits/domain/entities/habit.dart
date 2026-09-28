import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.name,
    required this.weekdayMask,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.activityId,
    this.description,
    this.targetTime,
    this.targetDuration,
  });

  final int id;
  final int? activityId;
  final String name;
  final String? description;
  final int weekdayMask;
  final DateTime? targetTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Duration? targetDuration;

  @override
  List<Object?> get props => [
    id,
    activityId,
    name,
    description,
    weekdayMask,
    targetTime,
    isActive,
    createdAt,
    updatedAt,
    targetDuration,
  ];
}
