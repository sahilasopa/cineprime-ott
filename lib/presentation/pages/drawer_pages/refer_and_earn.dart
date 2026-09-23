import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';
import 'package:share_plus/share_plus.dart';

import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import '../../../platform_utils.dart';
import '../../../providers/authentication_provider.dart';
import '../../../video_js_stub.dart';

class ReferAndEarnPage extends StatefulWidget {
  const ReferAndEarnPage({super.key});

  @override
  State<ReferAndEarnPage> createState() => _ReferAndEarnPageState();
}

class _ReferAndEarnPageState extends State<ReferAndEarnPage> {
  BetterPlayerController? _betterPlayerController;
  VideoJsController? _videoJsController;
  String? posterUrl;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    final contentProvider =
        Provider.of<ContentProvider>(context, listen: false);
    final videoUrl = contentProvider.getReferralVideoUrl();
    posterUrl = contentProvider.getReferralPosterUrl();
    if (videoUrl != null && posterUrl != null) {
      setState(() {
        PlatformUtils.isWeb
            ? _videoJsController = generateWebController(videoUrl, posterUrl!)
            : _betterPlayerController =
                generateMobileController(videoUrl, posterUrl!);
      });
      return;
    }
  }

  VideoJsController generateWebController(String videoUrl, String posterUrl) {
    return VideoJsController(
      "video-referral",
      videoJsOptions: VideoJsOptions(
        controls: true,
        loop: false,
        muted: false,
        poster: posterUrl,
        aspectRatio: '16:9',
        fluid: true,
        language: 'en',
        liveui: false,
        notSupportedMessage: 'This video format is not supported',
        playbackRates: [1, 1.5, 2],
        responsive: true,
        sources: [
          Source(videoUrl, "application/x-mpegURL"),
        ],
        suppressNotSupportedError: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);
    final user = authenticationProvider.getUser();
    if (user == null || user.referralCode.trim() == '') {
      Navigator.of(context).pop();
      return Container(
        color: AppColors.colorBackground,
      );
    }
    final shareText = contentProvider.getReferralText(user.referralCode);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Refer & Earn",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              TotalPointsCard(totalPoints: user.totalPointsEarned),
              SizedBox(height: 10),
              RemainingPointsCard(totalPoints: user.referralBalance),
              Container(
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: AppColors.colorSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.colorInputBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Your Referral Code",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: user.referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Referral code copied!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.colorPrimary,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.referralCode,
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.colorPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              "COPY\nCODE",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Share this code with a friend and both of you\ncould earn points.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Expanded(
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(vertical: 14),
                        //     decoration: BoxDecoration(
                        //       color: const Color(0xFF2D2D2D),
                        //       borderRadius: BorderRadius.circular(18),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: const [
                        //         Icon(Icons.receipt_long, color: Colors.white),
                        //         SizedBox(width: 8),
                        //         Text(
                        //           "Transactions",
                        //           style: TextStyle(color: Colors.white),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            label: 'Share',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () {
                              Share.share(shareText);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    "How It Works?",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PlatformUtils.isWeb
                      ? _videoJsController != null
                          ? VideoJsWidget(
                              videoJsController: _videoJsController!,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                            )
                          : CachedNetworkImage(
                              imageUrl: posterUrl ?? '',
                              errorWidget: (context, url, error) {
                                return Container();
                              },
                            )
                      : _betterPlayerController != null
                          ? BetterPlayer(
                              controller: _betterPlayerController!,
                            )
                          : CachedNetworkImage(
                              imageUrl: posterUrl ?? '',
                              errorWidget: (context, url, error) {
                                return Container();
                              },
                            ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  BetterPlayerController generateMobileController(
      String url, String posterUrl) {
    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: false,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableFullscreen: true,
          backgroundColor: Colors.transparent,
          controlBarColor: Colors.transparent,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 5 * 1024 * 1024,
          maxCacheSize: 11 * 1024 * 1024,
          maxCacheFileSize: 11 * 1024 * 1024,
        ),
      ),
    );

    return controller;
  }
}

class TotalPointsCard extends StatelessWidget {
  final double totalPoints;

  const TotalPointsCard({super.key, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        border: Border.all(color: AppColors.colorInputBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Points Earned',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            totalPoints.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

class RemainingPointsCard extends StatelessWidget {
  final double totalPoints;

  const RemainingPointsCard({super.key, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        border: Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Wallet Balance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            totalPoints.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.colorPrimary,
            ),
          )
        ],
      ),
    );
  }
}

