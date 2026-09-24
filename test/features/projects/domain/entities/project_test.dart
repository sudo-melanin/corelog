import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/features/projects/domain/entities/project.dart';
import 'package:corelog/features/projects/domain/entities/project_status.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1);
  final updatedAt = DateTime(2026, 1, 2);

  test('two projects with the same values are equal', () {
    final first = Project(
      id: 1,
      name: 'CoreLog',
      description: 'Personal productivity app',
      status: ProjectStatus.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final second = Project(
      id: 1,
      name: 'CoreLog',
      description: 'Personal productivity app',
      status: ProjectStatus.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(first, equals(second));
  });

  test('projects with different values are not equal', () {
    final first = Project(
      id: 1,
      name: 'CoreLog',
      description: 'Personal productivity app',
      status: ProjectStatus.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final second = Project(
      id: 2,
      name: 'CoreLog',
      description: 'Personal productivity app',
      status: ProjectStatus.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(first, isNot(equals(second)));
  });
}