// web_payment_service.dart
import 'dart:convert';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

/// Links to the JS function defined in index.html.
@JS('openRazorpayCheckout')
external void openRazorpayCheckoutJs(String optionsJson);

/// Opens the Razorpay checkout on web.
///
/// [options] is a Map of Razorpay options. [onSuccess] is the Dart callback
/// that will be called when the payment is successful.
void openRazorpay(Map<String, dynamic> options, Function(Map<String, dynamic>) onSuccess) {
  // Expose a Dart callback to JavaScript using globalThis.
  js_util.setProperty(js_util.globalThis, 'flutterRazorpayCallback', allowInterop((String jsonResponse) {
    final Map<String, dynamic> response = json.decode(jsonResponse);
    print("=======");
    print(response);
    print("=======");
    onSuccess(response);
  }));

  final jsonString = json.encode(options);
  openRazorpayCheckoutJs(jsonString);
}
