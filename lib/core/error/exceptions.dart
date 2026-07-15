class ServerException implements Exception {
  const ServerException({required this.message, this.code});
  final String message;
  final String? code;
  @override
  String toString() {
    return 'ServerException(code: $code, message: $message)';
  }
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);
  final String message;
  @override
  String toString() {
    return 'NetworkException(message: $message)';
  }
}

class CacheException implements Exception {
  const CacheException([this.message = 'Unable to access local data.']);
  final String message;
  @override
  String toString() {
    return 'CacheException(message: $message)';
  }
}

class AuthenticationException implements Exception {
  const AuthenticationException({required this.message, this.code});
  final String message;
  final String? code;
  @override
  String toString() {
    return 'AuthenticationException(code: $code, message: $message)';
  }
}
