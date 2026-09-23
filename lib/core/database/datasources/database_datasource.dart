import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';

import '../../error/error.dart';
import '../app_database.dart';

abstract interface class DatabaseDataSource {
  Future<Either<Failure, T>> transaction<T>(
    Future<T> Function() action,
  );
}

class DriftDatabaseDataSource implements DatabaseDataSource {
  const DriftDatabaseDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<Either<Failure, T>> transaction<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await _database.transaction(action);

      return Right(result);
    } on DriftWrappedException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on InvalidDataException catch (error) {
      return Left(DatabaseFailure(error.message));
    } on SqliteException catch (error) {
      return Left(DatabaseFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }
}