import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
/// Uses Equatable for value equality in tests
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure from server/API errors
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Failure from network/connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure from local cache operations
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Failure from input validation
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input']);
}
