import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/database/database.dart';

void main() {
  test('database provider creates an AppDatabase instance', () {
    final database = AppDatabase(NativeDatabase.memory());

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );

    addTearDown(() {
      container.dispose();
      database.close();
    });

    final result = container.read(databaseProvider);

    expect(result, same(database));
  });
}