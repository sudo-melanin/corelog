import '../app_database.dart';

abstract interface class DatabaseDataSource {
  Future<T> transaction<T>(Future<T> Function() action);
}

class DriftDatabaseDataSource implements DatabaseDataSource {
  const DriftDatabaseDataSource(this._database);
  final AppDatabase _database;
  @override
  Future<T> transaction<T>(Future<T> Function() action) {
    return _database.transaction(action);
  }
}
