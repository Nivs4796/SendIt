import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Simple logger that respects environment settings.
/// Only logs in development mode to prevent leaking debug info in production.
class AppLogger {
  AppLogger._();

  /// Log debug messages (development only)
  static void debug(String tag, String message) {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] $message');
    }
  }

  /// Log info messages (development only)
  static void info(String tag, String message) {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] ℹ️ $message');
    }
  }

  /// Log warning messages (development only)
  static void warning(String tag, String message) {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] ⚠️ $message');
    }
  }

  /// Log error messages (always logged for debugging critical issues)
  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    // Always log errors, but with less detail in production
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[$tag] ❌ $message');
      if (error != null) {
        debugPrint('[$tag] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$tag] Stack: $stackTrace');
      }
    } else {
      // In production, only log the message without details
      debugPrint('[$tag] Error: $message');
    }
  }

  /// Log network/socket events (development only)
  static void socket(String message) {
    if (AppConfig.enableDebugFeatures) {
      debugPrint('[Socket] $message');
    }
  }

  /// Log API calls (development only)
  static void api(String method, String url, {int? statusCode, String? error}) {
    if (AppConfig.enableDebugFeatures) {
      if (error != null) {
        debugPrint('[API] ❌ $method $url - $error');
      } else if (statusCode != null) {
        debugPrint('[API] $method $url - $statusCode');
      } else {
        debugPrint('[API] $method $url');
      }
    }
  }
}
