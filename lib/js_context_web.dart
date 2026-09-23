// js_context_web.dart
// Only compiled on web
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS()
external void fbq(String method, String event, [JSAny? params]);

void fbqWrapper(String method, String event, [Map<String, dynamic>? params]) {
  if (params != null) {
    fbq(method, event, params.jsify());
  } else {
    fbq(method, event);
  }
}
