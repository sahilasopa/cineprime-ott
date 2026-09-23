import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Hosted checkout for Sabpaisa PG 2.0. Loads the checkoutUrl returned by the
/// backend and invokes [onCompleted] once the gateway redirects to the
/// merchant return URL. The backend's PollPaymentStatus decides the actual
/// payment outcome, so completion here only means "checkout flow finished".
class SabpaisaCheckoutPage extends StatefulWidget {
  final String checkoutUrl;
  final String returnUrl;
  final VoidCallback onCompleted;

  const SabpaisaCheckoutPage({
    super.key,
    required this.checkoutUrl,
    required this.returnUrl,
    required this.onCompleted,
  });

  @override
  State<SabpaisaCheckoutPage> createState() => _SabpaisaCheckoutPageState();
}

class _SabpaisaCheckoutPageState extends State<SabpaisaCheckoutPage> {
  late final WebViewController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (_isReturnUrl(url)) {
              _complete();
              return NavigationDecision.prevent;
            }
            // UPI/intent deep links (GPay, PhonePe, etc.) can't render in a
            // webview — hand them to the OS.
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (_isReturnUrl(url)) _complete();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _isReturnUrl(String url) =>
      widget.returnUrl.isNotEmpty && url.startsWith(widget.returnUrl);

  void _complete() {
    if (_completed) return;
    _completed = true;
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
