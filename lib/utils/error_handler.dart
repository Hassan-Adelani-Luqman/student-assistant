import 'package:flutter/foundation.dart';

/// Centralized error handling utility
///
/// Provides consistent error handling, logging, and user-friendly error messages
/// across the application
class ErrorHandler {
  /// Storage error types
  static const String storageError = 'STORAGE_ERROR';
  static const String corruptedDataError = 'CORRUPTED_DATA';
  static const String permissionError = 'PERMISSION_ERROR';
  static const String outOfMemoryError = 'OUT_OF_MEMORY';
  static const String unknownError = 'UNKNOWN_ERROR';

  /// Log error with context
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      debugPrint('❌ ERROR in $context: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Storage errors
    if (errorString.contains('storage') ||
        errorString.contains('sharedpreferences') ||
        errorString.contains('cannot save') ||
        errorString.contains('failed to save')) {
      return 'Unable to save your data. Please check available storage space and try again.';
    }

    // Permission errors
    if (errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return 'Storage permission denied. Please check app permissions in settings.';
    }

    // Corrupted data errors
    if (errorString.contains('json') ||
        errorString.contains('format') ||
        errorString.contains('parse') ||
        errorString.contains('corrupt')) {
      return 'Data appears corrupted. We\'ll attempt to restore from backup.';
    }

    // Out of memory
    if (errorString.contains('memory') ||
        errorString.contains('out of space')) {
      return 'Insufficient storage space. Please free up some space and try again.';
    }

    // Network errors (future-proofing)
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Network connection issue. Please check your internet connection.';
    }

    // Validation errors
    if (errorString.contains('invalid') || errorString.contains('validation')) {
      return 'Invalid data detected. Please check your input and try again.';
    }

    // Default message
    return 'Something went wrong. Please try again later.';
  }

  /// Get recovery suggestion based on error
  static String getRecoverySuggestion(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('storage') || errorString.contains('save')) {
      return 'Try restarting the app or clearing some storage space.';
    }

    if (errorString.contains('permission')) {
      return 'Go to Settings > Apps > Student Assistant > Permissions and enable storage access.';
    }

    if (errorString.contains('corrupt')) {
      return 'Your data will be restored from the last backup automatically.';
    }

    if (errorString.contains('memory') || errorString.contains('space')) {
      return 'Delete unused apps or files to free up storage space.';
    }

    return 'Please try again in a moment. If the problem persists, restart the app.';
  }

  /// Check if error is recoverable
  static bool isRecoverable(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Non-recoverable errors
    if (errorString.contains('permission denied') &&
        !errorString.contains('temporarily')) {
      return false;
    }

    if (errorString.contains('critical') || errorString.contains('fatal')) {
      return false;
    }

    // Most errors are recoverable
    return true;
  }

  /// Sanitize error for logging (remove sensitive data)
  static String sanitizeError(dynamic error) {
    String errorString = error.toString();

    // Remove file paths
    errorString = errorString.replaceAll(RegExp(r'/[^\s]+/'), '[PATH]/');

    // Remove potential user data
    errorString = errorString.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL]',
    );

    return errorString;
  }

  /// Create error report
  static Map<String, dynamic> createErrorReport({
    required String context,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
      'error': sanitizeError(error),
      'errorType': _categorizeError(error),
      'stackTrace': stackTrace?.toString(),
      'isRecoverable': isRecoverable(error),
      'userMessage': getUserFriendlyMessage(error),
      'recoverySuggestion': getRecoverySuggestion(error),
      'additionalInfo': additionalInfo,
    };
  }

  /// Categorize error type
  static String _categorizeError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('storage') || errorString.contains('save')) {
      return storageError;
    }
    if (errorString.contains('corrupt') || errorString.contains('parse')) {
      return corruptedDataError;
    }
    if (errorString.contains('permission')) {
      return permissionError;
    }
    if (errorString.contains('memory') || errorString.contains('space')) {
      return outOfMemoryError;
    }

    return unknownError;
  }

  /// Handle storage operation with automatic retry
  static Future<T?> withRetry<T>({
    required Future<T> Function() operation,
    required String context,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    void Function(String)? onError,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempts++;
        logError(
          '$context (Attempt $attempts/$maxRetries)',
          e,
          stackTrace: stackTrace,
        );

        if (attempts >= maxRetries) {
          final message = getUserFriendlyMessage(e);
          onError?.call(message);
          return null;
        }

        // Wait before retrying
        await Future.delayed(retryDelay);
      }
    }

    return null;
  }

  /// Execute operation with error handling
  static Future<T?> execute<T>({
    required Future<T> Function() operation,
    required String context,
    T? defaultValue,
    void Function(String)? onError,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      logError(context, e, stackTrace: stackTrace);
      final message = getUserFriendlyMessage(e);
      onError?.call(message);
      return defaultValue;
    }
  }
}

/// Custom exception types for better error handling
class StorageException implements Exception {
  final String message;
  final String? code;

  StorageException(this.message, {this.code});

  @override
  String toString() =>
      'StorageException: $message ${code != null ? "($code)" : ""}';
}

class DataCorruptionException implements Exception {
  final String message;

  DataCorruptionException(this.message);

  @override
  String toString() => 'DataCorruptionException: $message';
}

class ValidationException implements Exception {
  final String message;
  final String field;

  ValidationException(this.message, this.field);

  @override
  String toString() => 'ValidationException: $message (field: $field)';
}
