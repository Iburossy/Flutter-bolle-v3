import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Failure related to server errors
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Failure related to network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// Failure related to cache operations
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Failure related to authentication issues
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}
