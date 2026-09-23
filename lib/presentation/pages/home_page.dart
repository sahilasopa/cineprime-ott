import 'dart:ui';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/pages/fragments/search_page.dart';
import 'package:cineprime/presentation/pages/fragments/sections_page.dart';
import 'package:cineprime/presentation/pages/fragments/my_list_page.dart';
import 'package:cineprime/presentation/pages/media/downloads_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/profile_page.dart';
import 'package:cineprime/presentation/components/notification_permission_modal.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/providers/home_page_provider.dart';
import 'package:cineprime/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'fragments/sections_page_web.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _homeSectionsPageKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isDrawerOpen = false;
  String? firstReelId;

  @override
  void initState() {
    super.initState();
    if (PlatformUtils.isIOS) {
      requestTrackingPermission();
    } else {
      FacebookAppEvents().setAdvertiserTracking(enabled: true);
    }
    // Consume pending push notification (e.g. app opened from killed state by notification tap)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await NotificationService().tryConsume(context);
      }
    });
    // Show notification permission modal if needed (for users already logged in)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        await NotificationPermissionModal.showIfNeeded(context);
      }
    });
  }

  Future<void> requestTrackingPermission() async {
    final status = await AppTrackingTransparency.requestTrackingAuthorization();

    if (status == TrackingStatus.authorized) {
      FacebookAppEvents().setAdvertiserTracking(enabled: true);
    } else if (status == TrackingStatus.denied) {
      FacebookAppEvents().setAdvertiserTracking(enabled: false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deepLinkProvider = Provider.of<HomePageProvider>(context);
    if (deepLinkProvider.firstReelId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          firstReelId = deepLinkProvider.firstReelId;
          _currentIndex = 3;
        });
        deepLinkProvider.redirectToReels(null);
      });
    }
  }

  static bool _isAbsoluteImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    precacheImage(const AssetImage("assets/images/cineprime-logo.png"), context);
    precacheImage(const AssetImage("assets/images/cineprime-icon.png"), context);
    for (var movie in contentProvider.getMovies()) {
      if (_isAbsoluteImageUrl(movie.verticalPosterUrl)) {
        precacheImage(CachedNetworkImageProvider(movie.verticalPosterUrl), context);
      }
    }
    for (var series in contentProvider.getSeries()) {
      if (_isAbsoluteImageUrl(series.verticalPosterUrl)) {
        precacheImage(CachedNetworkImageProvider(series.verticalPosterUrl), context);
      }
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (_currentIndex == 0) {
          if (_scaffoldKey.currentState != null) {
            if (_scaffoldKey.currentState!.isEndDrawerOpen) {
              _scaffoldKey.currentState!.closeEndDrawer();
              return;
            }
          }
          final shouldExit = await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.7),
            builder: (context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.colorBackground.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.colorPrimary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.colorPrimary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.circleXmark,
                              color: AppColors.colorPrimary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Exit App?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Are you sure you want to leave?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.colorPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Exit",
                                    style: TextStyle(
                                      color: AppColors.colorOnGold,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
          if (shouldExit ?? false) {
            SystemNavigator.pop(animated: true);
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: AnimatedSlide(
          offset: _isDrawerOpen ? const Offset(0, 1) : Offset.zero,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _isDrawerOpen ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: CineprimeBottomNav(
              currentIndex: _currentIndex,
              showDownloads: !kIsWeb,
              onTap: (idx) => setState(() => _currentIndex = idx),
            ),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex.clamp(0, kIsWeb ? 3 : 4),
          children: [
            if (kIsWeb)
              SectionsPageWeb(
                onDrawerChanged: (isOpen) {
                  setState(() {
                    _isDrawerOpen = isOpen;
                  });
                },
              ),
            if (!kIsWeb)
              SectionsPage(
                scaffoldKey: _homeSectionsPageKey,
                onSearchTap: () => setState(() => _currentIndex = 1),
              ),
            const SearchPage(),
            const MyListPage(),
            if (!kIsWeb) const DownloadsPage(),
            const ProfilePage(),
          ],
        ),
      ),
    );
  }
}
