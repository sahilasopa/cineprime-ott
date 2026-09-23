import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:cineprime/providers/home_page_provider.dart';
import 'package:provider/provider.dart';

class DeepLinkHandler extends StatefulWidget {
  final Widget child;

  const DeepLinkHandler({super.key, required this.child});

  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLink();
  }

  Future<void> _initDeepLink() async {
    // Handle the initial link if the app was launched by a deep link.
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (e) {
      debugPrint("Error getting initial deep link: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleLink(uri);
      },
      onError: (error) {
        debugPrint("Error in deep link stream: $error");
      },
    );
  }

  void _handleLink(Uri uri) {
    if ((uri.scheme == "butterfly" && uri.host == "reel") || uri.scheme == 'https') {
      final reelId = uri.queryParameters['id'];
      if (reelId != null) {
        Provider.of<HomePageProvider>(context, listen: false)
            .redirectToReels(reelId);
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
