abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
