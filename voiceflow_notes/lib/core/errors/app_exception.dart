class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() => '[$code] $message';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.stackTrace});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.stackTrace});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.stackTrace});
}
