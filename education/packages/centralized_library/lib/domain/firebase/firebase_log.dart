import 'package:firebase_crashlytics/firebase_crashlytics.dart';

extension CrashlyticsExtensions on FirebaseCrashlytics {
  /// Log a warning (non-fatal error)
  Future<void> logWarning(
      String message, {
        StackTrace? stackTrace,
        String? reason,
        Map<String, dynamic>? context,
      }) async {
    await log('WARNING: $message');

    // Add context as custom keys
    if (context != null) {
      for (final entry in context.entries) {
        await setCustomKey(entry.key, entry.value.toString());
      }
    }

    await recordError(
      Exception(message),
      stackTrace ?? StackTrace.current,
      reason: reason ?? 'Warning',
      fatal: false,
    );
  }

  /// Log an error (non-fatal)
  Future<void> logError(
      dynamic error, {
        StackTrace? stackTrace,
        String? reason,
        Map<String, dynamic>? context,
      }) async {
    await log('ERROR: ${error.toString()}');

    if (context != null) {
      for (final entry in context.entries) {
        await setCustomKey(entry.key, entry.value.toString());
      }
    }

    await recordError(
      error,
      stackTrace ?? StackTrace.current,
      reason: reason,
      fatal: false,
    );
  }

  /// Log a fatal error
  Future<void> logFatalError(
      dynamic error, {
        StackTrace? stackTrace,
        String? reason,
        Map<String, dynamic>? context,
      }) async {
    await log('FATAL ERROR: ${error.toString()}');

    if (context != null) {
      for (final entry in context.entries) {
        await setCustomKey(entry.key, entry.value.toString());
      }
    }

    await recordError(
      error,
      stackTrace ?? StackTrace.current,
      reason: reason,
      fatal: true,
    );
  }

  /// Log an info message (breadcrumb only)
  Future<void> logInfo(String message) async {
    await log('INFO: $message');
  }

  /// Log with custom context
  Future<void> logWithContext(
      String message,
      Map<String, dynamic> context,
      ) async {
    await log(message);
    for (final entry in context.entries) {
      await setCustomKey(entry.key, entry.value.toString());
    }
  }
}