import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('database creates all tables successfully', () async {
  final projects = await database.select(database.projects).get();
  final tasks = await database.select(database.tasks).get();
  final timeBlocks = await database.select(database.timeBlocks).get();
  final habits = await database.select(database.habits).get();
  final habitOccurrences =
      await database.select(database.habitOccurrences).get();

  expect(projects, isEmpty);
  expect(tasks, isEmpty);
  expect(timeBlocks, isEmpty);
  expect(habits, isEmpty);
  expect(habitOccurrences, isEmpty);
});

  test('project can be inserted and read back', () async {
  final now = DateTime.now();

  await database.into(database.projects).insert(
    ProjectsCompanion.insert(
      name: 'CoreLog',
      description: const Value('CoreLog development'),
      createdAt: now,
      updatedAt: now,
    ),
  );

  final projects = await database.select(database.projects).get();

  expect(projects, hasLength(1));
  expect(projects.first.name, 'CoreLog');
  expect(projects.first.description, 'CoreLog development');
  expect(projects.first.status, 'active');
});
}
