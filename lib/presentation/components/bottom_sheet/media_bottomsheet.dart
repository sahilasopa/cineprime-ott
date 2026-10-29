import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/pages/media/episode_details_page.dart';
import 'package:cineprime/trailer_player_stub.dart' if (dart.library.html) 'package:cineprime/presentation/pages/media/trailer_player_web.dart';
import 'package:cineprime/episode_player_stub.dart' if (dart.library.html) 'package:cineprime/presentation/pages/media/episode_player_page_web.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pages/authentication/login_screen.dart';
import '../../pages/media/movie_details_page.dart';
import '../../pages/media/trailer_player.dart';
import '../../pages/media/tv_show_details_page.dart';
import '../../pages/media/episode_player_page.dart';
import 'package:cineprime/services/authentication_service.dart';

/// Opens external URL and records click for analytics (KPIs). Platform is sent as android/ios/web.
/// Can be used from bottom sheet or from Upcoming tab.
Future<void> handleExternalItemTap(BaseItem baseItem) async {
  final url = baseItem.externalUrl!.trim();
  final rawPlatform = PlatformUtils.operatingSystem;
  final platform = rawPlatform == 'ios' || rawPlatform == 'android' ? rawPlatform : 'web';
  final clickUrl = APIPathHelper.getExternalItemClickUrl(baseItem.id);
  final sessionId = await AuthenticationService().getSessionId();
  final headers = {
    'Content-Type': 'application/json',
    'Platform': platform,
  };
  if (sessionId != null) {
    headers['Cookie'] = 'sessionid=$sessionId';
  }
  try {
    await http.post(
      Uri.parse(clickUrl),
      headers: headers,
      body: jsonEncode({'platform': platform}),
    );
  } catch (_) {}
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
}

void showBottomSheetOrNavigate(BuildContext context, BaseItem baseItem) {
  // External items: open URL and record click (fire-and-forget)
  if (baseItem.mediaType == MediaType.external &&
      baseItem.externalUrl != null &&
      baseItem.externalUrl!.trim().isNotEmpty) {
    handleExternalItemTap(baseItem);
    return;
  }

  final auth = Provider.of<AuthenticationProvider>(context, listen: false);
  final user = auth.getUser();

  final now = DateTime.now();
  final isFuture = now.isBefore(baseItem.releaseTime.toLocal());
  final isLoggedIn = user != null;
  final hasPlan = user?.userSubscription != null;

  // 1) Unreleased → go straight to trailer (or details for series)
  if (isFuture) {
    if (baseItem.mediaType == MediaType.series) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TvShowDetailsPage(baseItem)),
      );
    } else {
      // Use web player on web, native elsewhere
      final widget = kIsWeb
          ? TrailerVideoPlayerWeb(baseItem)
          : TrailerVideoPlayer(baseItem);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget),
      );
    }
    return;
  }

  // 2) Not logged in → series can open details (non–login-mandatory); others go to Login
  if (!isLoggedIn) {
    if (baseItem.mediaType == MediaType.series) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TvShowDetailsPage(baseItem)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
    return;
  }

  // 3) Premium + no plan
  if (baseItem.isPremium && !hasPlan) {
    if (baseItem.mediaType == MediaType.series) {
      // Keep series flow to details (subscribe CTA there)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TvShowDetailsPage(baseItem)),
      );
    } else {
      // Movies/Episodes go straight to plans
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlansListPage()),
      );
    }
    return;
  }

  // 4) Otherwise → open appropriate details
  if (baseItem.mediaType == MediaType.episode) {
    // Use web player on web, native elsewhere
    final widget = kIsWeb
        ? EpisodePlayerPageWeb(baseItem)
        : EpisodePlayerPage(baseItem);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget),
    );
  } else {
    final page = switch (baseItem.mediaType) {
      MediaType.movie => MovieDetailsPage(baseItem),
      MediaType.series => TvShowDetailsPage(baseItem),
      _ => EpisodeDetailsPage(baseItem),
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
