// js_stub.dart
// This stub is used on non-web platforms (Android, iOS, desktop).

class JsContext {
  dynamic callMethod(String method, List args) {
    // No-op for non-web platforms
    return null;
  }
}

// No-op global context (mirrors the web version)
final JsContext context = JsContext();

/// Stub for fbq() so non-web builds don't error.
void fbq(String method, String event, [Map<String, dynamic>? params]) {
  // No-op for non-web platforms
}

/// Stub for fbqWrapper() so code compiles cleanly everywhere.
void fbqWrapper(String method, String event, [Map<String, dynamic>? params]) {
  // No-op for non-web platforms
}

/// Stub extension to mirror js_interop_unsafe's jsify()
extension JsInteropStub on Object? {
  dynamic jsify() => this;
}
