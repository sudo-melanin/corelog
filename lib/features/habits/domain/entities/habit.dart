import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.name,
    required this.weekdayMask,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.projectId,
    this.description,
    this.targetTime,
  });

  final int id;
  final int? projectId;
  final String name;
  final String? description;
  final int weekdayMask;
  final DateTime? targetTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        weekdayMask,
        targetTime,
        isActive,
        createdAt,
        updatedAt,
      ];
}