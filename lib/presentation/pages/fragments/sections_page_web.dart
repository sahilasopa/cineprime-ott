import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/media/media_tile_web.dart';
import 'package:cineprime/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/authentication_provider.dart';
import '../../components/bottom_sheet/media_bottomsheet.dart';
import '../authentication/login_screen.dart';

class SectionsPageWeb extends StatefulWidget {
  final void Function(bool)? onDrawerChanged;

  const SectionsPageWeb({super.key, this.onDrawerChanged});

  @override
  State<SectionsPageWeb> createState() => _SectionsPageWebState();
}

double _getAspectRatio(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > 1200) return 2.5; // PCs
  if (width > 600) return 1.8; // Tablets
  return 1; // Phones
}

double _getViewportFraction(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > 1200) return 0.32;
  if (width > 600) return 0.32;
  return 0.72;
}

class _SectionsPageWebState extends State<SectionsPageWeb> {
  int dotPosition = 0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final inAppNotificationProvider =
        Provider.of<InAppNotificationProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight + statusBarHeight;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      key: _key,
      onDrawerChanged: widget.onDrawerChanged,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () =>
                Provider.of<ContentProvider>(context, listen: false).init(),
            color: AppColors.colorPrimary,
            backgroundColor: AppColors.colorBackground,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: contentProvider.getStatus() == Status.fetching
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: kToolbarHeight),
                        const SizedBox(height: 10),
                        CarouselSlider(
                          options: CarouselOptions(
                            initialPage: 0,
                            aspectRatio: _getAspectRatio(context),
                            viewportFraction: _getViewportFraction(context),
                            enlargeCenterPage: true,
                            autoPlay: false,
                          ),
                          items: [1].map((_) {
                            return Builder(
                              builder: (BuildContext context) {
                                return AspectRatio(
                                  aspectRatio: _getAspectRatio(context),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: const Color(0xFF1F1F1F),
                                        highlightColor: Colors.grey[800]!,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1F1F1F),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Image.asset(
                                          "assets/images/cineprime-icon.png",
                                          width: 120,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        const ShimmerTile(),
                        const ShimmerTile(),
                        const ShimmerTileHorizontal(),
                        const ShimmerTile(),
                        SizedBox(height: kBottomNavigationBarHeight + 50),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: kToolbarHeight),
                        if (contentProvider.getPosters().isNotEmpty)
                          const SizedBox(height: kToolbarHeight + 10),
                        if (contentProvider.getPosters().isEmpty)
                          const SizedBox(height: kToolbarHeight),
                        if (contentProvider.getPosters().isEmpty &&
                            (contentProvider.getMovies().isEmpty ||
                                contentProvider.getSeries().isEmpty))
                          const SizedBox(height: 10),
                        if (contentProvider.getPosters().isEmpty &&
                            (contentProvider.getMovies().isEmpty ||
                                contentProvider.getSeries().isEmpty))
                          CarouselSlider(
                            options: CarouselOptions(
                              initialPage: 0,
                              aspectRatio: _getAspectRatio(context),
                              viewportFraction: _getViewportFraction(context),
                              enlargeCenterPage: true,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 7),
                            ),
                            items: [1].map((slide) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return AspectRatio(
                                    aspectRatio: 1,
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[400]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          )
                        else if (contentProvider.getPosters().isEmpty)
                          Container()
                        else
                          CarouselSlider(
                            options: CarouselOptions(
                              initialPage: 0,
                              aspectRatio: _getAspectRatio(context),
                              viewportFraction: _getViewportFraction(context),
                              enlargeCenterPage: true,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 7),
                            ),
                            items: contentProvider.getPosters().map((slide) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      showBottomSheetOrNavigate(context, slide);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        useOldImageOnUrlChange: false,
                                        imageUrl: slide.featuredPosterUrl,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.grey[400]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.grey),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.grey[400]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(color: Colors.grey),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 8),
                        if (contentProvider.getMovies().isEmpty &&
                            contentProvider.getSeries().isEmpty)
                          const Column(children: [
                            ShimmerTile(),
                            ShimmerTile(),
                            ShimmerTileHorizontal(),
                            ShimmerTile(),
                          ])
                        else
                          Column(
                            children: contentProvider
                                .getSections()
                                .skip(1)
                                .map((section) {
                              return MediaTileWeb(section);
                            }).toList(),
                          ),
                        SizedBox(height: kBottomNavigationBarHeight + 50),
                        // if (PlatformUtils.isWeb) FooterWithBadges(),
                      ],
                    ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: appBarHeight,
                  color: AppColors.colorBackground.withValues(alpha: 0.9),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    foregroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    centerTitle: true,
                    title: Image.asset(
                      "assets/images/cineprime-logo.png",
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    leading: IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 25),
                      onPressed: () => _key.currentState?.openDrawer(),
                    ),
                    actions: [
                      if (user == null || user.userSubscription == null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PlansListPage()));
                          },
                          child: Container(
                            width: 100,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2EB193),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "Subscribe!",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      if (user == null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => LoginPage()));
                          },
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2EB193),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 5),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_rounded,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => NotificationsPage()),
                              );
                            },
                          ),
                          if (inAppNotificationProvider
                              .getNotifications()
                              .isNotEmpty)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  inAppNotificationProvider
                                      .getNotifications()
                                      .length
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded,
                            color: Colors.white),
                        onPressed: () {
                          Share.share(
                            contentProvider.getShareUrl(),
                            subject: contentProvider.getShareText(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FooterWithBadges extends StatelessWidget {
  const FooterWithBadges({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Copyright Text
          Flexible(
            flex: 2,
            child: Text(
              '© 2025 VOOVI DIGITAL PRIVATE LIMITED. All Rights Reserved. All videos and shows on this platform are trademarks of, and all related images and content are the property of, Voovi Digital. Duplication and copy of this is strictly prohibited. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
              textAlign: TextAlign.left,
            ),
          ),

          // CENTER: Empty space
          const Spacer(flex: 1),

          // RIGHT: App download section
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Download Cineprime Apps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl(
                        "https://play.google.com/store/apps/details?id=app.cineprimeott.app",
                      ),
                      child: Image.asset(
                        'assets/images/google-play.webp',
                        width: 140,
                        height: 50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _launchUrl("http://apps.apple.com/app/a/id"),
                      child: Image.asset(
                        'assets/images/apple.webp',
                        width: 140,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
