import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:corelog/core/database/app_database.dart';
import 'package:corelog/features/history/data/repositories/activity_history_repository_impl.dart';
import 'package:corelog/features/history/domain/entities/activity_history.dart';
import 'package:corelog/features/history/domain/entities/history_outcome.dart';

void main() {
  late AppDatabase database;
  late ActivityHistoryRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ActivityHistoryRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and retrieves history record', () async {
    final history = ActivityHistory(
      id: 0,
      taskId: 1,
      activityId: 10,
      taskTitle: 'Flutter development',
      plannedStart: DateTime(2026, 1, 1, 14),
      plannedEnd: DateTime(2026, 1, 1, 15, 30),
      outcome: HistoryOutcome.completed,
      occurredAt: DateTime(2026, 1, 1, 15, 45),
      actualDuration: const Duration(minutes: 90),
    );

    final createResult = await repository.createHistory(history);

    expect(createResult.isRight(), isTrue);

    final createdHistory = createResult.getOrElse(
      (_) => throw StateError('Expected history creation to succeed.'),
    );

    expect(createdHistory.taskId, history.taskId);
    expect(createdHistory.activityId, history.activityId);
    expect(createdHistory.taskTitle, history.taskTitle);
    expect(createdHistory.plannedStart, history.plannedStart);
    expect(createdHistory.plannedEnd, history.plannedEnd);
    expect(createdHistory.occurredAt, history.occurredAt);
    expect(createdHistory.actualDuration, history.actualDuration);

    final getResult = await repository.getHistoryById(createdHistory.id);

    expect(getResult.isRight(), isTrue);

    final retrievedHistory = getResult.getOrElse(
      (_) => throw StateError('Expected history retrieval to succeed.'),
    );

    expect(retrievedHistory, isNotNull);
    expect(retrievedHistory!.id, createdHistory.id);
    expect(retrievedHistory.taskId, history.taskId);
    expect(retrievedHistory.activityId, history.activityId);
    expect(retrievedHistory.taskTitle, history.taskTitle);
    expect(retrievedHistory.plannedStart, history.plannedStart);
    expect(retrievedHistory.plannedEnd, history.plannedEnd);
    expect(retrievedHistory.occurredAt, history.occurredAt);
    expect(retrievedHistory.actualDuration, history.actualDuration);
  });

  test('returns empty history when no records exist', () async {
    final result = await repository.getHistory();

    expect(result.isRight(), isTrue);

    final history = result.getOrElse(
      (_) => throw StateError('Expected history retrieval to succeed.'),
    );

    expect(history, isEmpty);
  });

  test('gets history by activity', () async {
    final firstHistory = ActivityHistory(
      id: 0,
      taskId: 1,
      activityId: 10,
      taskTitle: 'Flutter development',
      outcome: HistoryOutcome.completed,
      occurredAt: DateTime(2026, 1, 1, 15),
      actualDuration: const Duration(minutes: 60),
    );

    final secondHistory = ActivityHistory(
      id: 0,
      taskId: 2,
      activityId: 20,
      taskTitle: 'Trading',
      outcome: HistoryOutcome.completed,
      occurredAt: DateTime(2026, 1, 1, 16),
      actualDuration: const Duration(minutes: 30),
    );

    await repository.createHistory(firstHistory);
    await repository.createHistory(secondHistory);

    final result = await repository.getHistoryByActivity(10);

    expect(result.isRight(), isTrue);

    final history = result.getOrElse(
      (_) => throw StateError('Expected history retrieval to succeed.'),
    );

    expect(history, hasLength(1));
    expect(history.single.taskId, 1);
    expect(history.single.activityId, 10);
    expect(history.single.taskTitle, 'Flutter development');
  });

  test('gets history by task', () async {
    final firstHistory = ActivityHistory(
      id: 0,
      taskId: 1,
      activityId: 10,
      taskTitle: 'Flutter development',
      outcome: HistoryOutcome.completed,
      occurredAt: DateTime(2026, 1, 1, 15),
      actualDuration: const Duration(minutes: 60),
    );

    final secondHistory = ActivityHistory(
      id: 0,
      taskId: 2,
      activityId: 10,
      taskTitle: 'Write documentation',
      outcome: HistoryOutcome.completed,
      occurredAt: DateTime(2026, 1, 1, 16),
      actualDuration: const Duration(minutes: 30),
    );

    await repository.createHistory(firstHistory);
    await repository.createHistory(secondHistory);

    final result = await repository.getHistoryByTask(1);

    expect(result.isRight(), isTrue);

    final history = result.getOrElse(
      (_) => throw StateError('Expected history retrieval to succeed.'),
    );

    expect(history, hasLength(1));
    expect(history.single.taskId, 1);
    expect(history.single.activityId, 10);
    expect(history.single.taskTitle, 'Flutter development');
  });
}
