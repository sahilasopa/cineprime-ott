import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cineprime/platform_utils.dart';

class CrashlyticsLogger {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  static void init() {
    if (PlatformUtils.isWeb) return;

    FlutterError.onError = (FlutterErrorDetails details) {
      if (_shouldIgnore(details.exception.toString())) return;
      _crashlytics.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (_shouldIgnore(error.toString())) return true;
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    // Optional: log zone-level uncaught async errors
    runZonedGuarded(() {}, (error, stack) {
      if (_shouldIgnore(error.toString())) return;
      _crashlytics.recordError(error, stack, fatal: true);
    });
  }

  /// Log a message (visible in Crashlytics breadcrumbs)
  static void log(String message) {
    _crashlytics.log(message);
  }

  /// Record a caught error
  static void recordError(Object error, StackTrace stack,
      {bool fatal = false}) {
    if (_shouldIgnore(error.toString())) return;
    _crashlytics.recordError(error, stack, fatal: fatal);
  }

  /// Set user ID
  static void setUser(String userId) {
    _crashlytics.setUserIdentifier(userId);
  }

  /// Add a custom context key-value
  static void setContext(String key, Object? value) {
    if (value != null) {
      _crashlytics.setCustomKey(key, value.toString());
    }
  }

  /// Track current screen/page
  static void setPage(String pageName) {
    setContext('current_page', pageName);
  }

  /// Clears optional context (you can override with empty/unknown)
  static void clearContext() {
    setContext('current_page', 'unknown');
  }

  static bool _shouldIgnore(String error) {
    return error.contains('Software caused connection abort') ||
        error.contains('Video player had error') ||
        error.contains('MediaCodecVideoRenderer error');
  }
}
