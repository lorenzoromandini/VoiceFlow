import 'dart:developer';
import 'package:voiceflow_notes/core/errors/app_exception.dart';
import 'package:voiceflow_notes/core/utils/result.dart';

typedef AsyncOperation<T> = Future<T> Function();

class AsyncHandler {
  static Future<Result<T>> execute<T>(
    AsyncOperation<T> operation, {
    String? operationName,
  }) async {
    try {
      final result = await operation();
      return Success(result);
    } on AppException catch (e, stackTrace) {
      log(
        'AppException in ${operationName ?? 'operation'}: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      return Failure(e);
    } catch (e, stackTrace) {
      log(
        'Unexpected error in ${operationName ?? 'operation'}: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Failure(
        AppException(
          'An unexpected error occurred',
          code: 'UNKNOWN_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
