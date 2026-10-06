import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/database.dart' hide Activity;
import 'package:corelog/features/activities/data/repositories/activity_repository_impl.dart';
import 'package:corelog/features/activities/domain/entities/activity.dart';

void main() {
  late AppDatabase database;
  late ActivityRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ActivityRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ActivityRepositoryImpl', () {
    test('creates and retrieves an activity', () async {
      final now = DateTime(2026, 1, 1, 10);

      final activity = Activity(
        id: 0,
        name: 'Flutter Development',
        description: 'Building Flutter applications',
        isActive: true,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      );

      final createResult = await repository.createActivity(activity);

      expect(createResult.isRight(), isTrue);

      final createdActivity = createResult.getRight().toNullable();

      expect(createdActivity, isNotNull);
      expect(createdActivity!.name, 'Flutter Development');
      expect(createdActivity.description, 'Building Flutter applications');
      expect(createdActivity.isActive, isTrue);
      expect(createdActivity.createdAt, now);
      expect(createdActivity.updatedAt, now);

      final getResult =
          await repository.getActivityById(createdActivity.id);

      expect(getResult.isRight(), isTrue);

      final retrievedActivity = getResult.getRight().toNullable();

      expect(retrievedActivity, isNotNull);
      expect(retrievedActivity!.id, createdActivity.id);
      expect(retrievedActivity.name, 'Flutter Development');
    });

    test('returns all activities', () async {
      final firstActivity = Activity(
        id: 0,
        name: 'Flutter Development',
        isActive: true,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      );

      final secondActivity = Activity(
        id: 0,
        name: 'Fitness',
        isActive: true,
        createdAt: DateTime(2026, 1, 2, 10),
        updatedAt: DateTime(2026, 1, 2, 10),
      );

     final firstResult = await repository.createActivity(firstActivity);
    final secondResult = await repository.createActivity(secondActivity);

    expect(firstResult.isRight(), isTrue);
    expect(
      secondResult.isRight(),
      isTrue,
      reason: secondResult.fold(
        (failure) => failure.toString(),
        (_) => 'Second activity was created successfully.',
      ),
    );

      final result = await repository.getActivities();

      expect(result.isRight(), isTrue);

      final activities = result.getRight().toNullable();

      expect(activities, isNotNull);
      expect(activities, hasLength(2));
      expect(
        activities!.map((activity) => activity.name),
        containsAll([
          'Flutter Development',
          'Fitness',
        ]),
      );
    });

    test('updates an activity', () async {
      final originalActivity = Activity(
        id: 0,
        name: 'Flutter Development',
        description: 'Original description',
        isActive: true,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      );

      final createResult =
          await repository.createActivity(originalActivity);

      final createdActivity = createResult.getRight().toNullable();

      expect(createdActivity, isNotNull);

      final updatedActivity = Activity(
        id: createdActivity!.id,
        name: 'Flutter Engineering',
        description: 'Updated description',
        isActive: false,
        createdAt: createdActivity.createdAt,
        updatedAt: DateTime(2026, 1, 2, 10),
      );

      final updateResult =
          await repository.updateActivity(updatedActivity);

      expect(updateResult.isRight(), isTrue);

      final result =
          await repository.getActivityById(createdActivity.id);

      final activity = result.getRight().toNullable();

      expect(activity, isNotNull);
      expect(activity!.name, 'Flutter Engineering');
      expect(activity.description, 'Updated description');
      expect(activity.isActive, isFalse);
      expect(activity.updatedAt, DateTime(2026, 1, 2, 10));
    });

    test('deletes an activity', () async {
      final activity = Activity(
        id: 0,
        name: 'Trading',
        isActive: true,
        createdAt: DateTime(2026, 1, 1, 10),
        updatedAt: DateTime(2026, 1, 1, 10),
      );

      final createResult = await repository.createActivity(activity);

      final createdActivity = createResult.getRight().toNullable();

      expect(createdActivity, isNotNull);

      final deleteResult =
          await repository.deleteActivity(createdActivity!.id);

      expect(deleteResult.isRight(), isTrue);

      final getResult =
          await repository.getActivityById(createdActivity.id);

      expect(getResult.isRight(), isTrue);
      expect(getResult.getRight().toNullable(), isNull);
    });
  });
}