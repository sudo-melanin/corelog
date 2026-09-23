import 'package:equatable/equatable.dart';

import 'project_status.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final int id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        createdAt,
        updatedAt,
      ];
}