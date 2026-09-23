import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cineprime/platform_utils.dart';
import '../js_stub.dart' if (dart.library.js_interop) '../js_context_web.dart' as js;

class LoggingService {
  final FirebaseAnalytics _googleAnalytics;
  final FacebookAppEvents _facebookAnalytics;
  final isWeb = PlatformUtils.isWeb;

  LoggingService._(this._googleAnalytics, this._facebookAnalytics);

  static final LoggingService _instance = LoggingService._(
    FirebaseAnalytics.instance,
    FacebookAppEvents(),
  );

  factory LoggingService() {
    return _instance;
  }

  /// Helper for Meta Pixel
  void _logToMetaPixel(String event, [Map<String, dynamic>? params]) {
    try {
      final standardEvents = ["PageView", "Purchase", "AddToCart", "ViewContent"];
      final method = standardEvents.contains(event) ? 'track' : 'trackCustom';

      if (params != null && params.isNotEmpty) {
        js.fbqWrapper(method, event, params);
      } else {
        js.fbq(method, event);
      }
    } catch (e) {
      print("Error logging to Meta Pixel: $e");
    }
  }

  /// Logs a general event to GA, FB App Events, and Meta Pixel (web).
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (isWeb) {
      _logToMetaPixel(name, parameters);
    }

    try {
      await _googleAnalytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print("Error logging to Google Analytics: $e");
    }

    try {
      _facebookAnalytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print("Error logging to Facebook Analytics: $e");
    }
  }

  /// Logs a purchase event across platforms.
  Future<void> logPurchase(double purchaseValue, {String currency = 'INR'}) async {
    if (isWeb) {
      _logToMetaPixel("Purchase", {"value": purchaseValue, "currency": currency});
    }

    try {
      await _googleAnalytics.logPurchase(value: purchaseValue, currency: currency);
    } catch (e) {
      print("Error logging purchase to Google Analytics: $e");
    }

    try {
      _facebookAnalytics.logPurchase(amount: purchaseValue, currency: currency);
    } catch (e) {
      print("Error logging purchase to Facebook Analytics: $e");
    }
  }

  void logScreenView(String screenName) {
    if (isWeb) {
      _logToMetaPixel("ScreenView", {"screen": screenName});
    }

    FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  void setCrashlyticsScreen(String screenName) {
    if (isWeb) return;
    FirebaseCrashlytics.instance.setCustomKey('current_screen', screenName);
  }
}
