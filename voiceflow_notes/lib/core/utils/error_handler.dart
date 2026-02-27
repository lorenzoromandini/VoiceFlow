import 'package:flutter/material.dart';
import '../errors/app_exception.dart';

class ErrorHandler {
  static String getUserFriendlyMessage(AppException error) {
    return switch (error) {
      DatabaseException() => 'Unable to save your note. Please try again.',
      NetworkException() => 'No internet connection. Your note is saved locally.',
      ValidationException() => error.message,
      _ => 'Something went wrong. Please try again.',
    };
  }

  static void showError(BuildContext context, AppException error) {
    final message = getUserFriendlyMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
