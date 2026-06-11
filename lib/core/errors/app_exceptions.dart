class AppException implements Exception {
  final String message;
  final String? code;
  AppException(this.message, {this.code});
  @override
  String toString() => message;
}

class FirebaseException extends AppException {
  FirebaseException(super.message, {super.code});
}

class RouterOSException extends AppException {
  RouterOSException(super.message, {super.code});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code});
}
