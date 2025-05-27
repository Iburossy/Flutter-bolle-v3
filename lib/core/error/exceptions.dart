/// Exception thrown when a server error occurs
class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
}

/// Exception thrown when a network error occurs
class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});
}

/// Exception thrown when a cache error occurs
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}

/// Exception thrown when an authentication error occurs
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});
}
