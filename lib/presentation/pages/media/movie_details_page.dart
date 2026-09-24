import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';

import '../../../providers/authentication_provider.dart';
import '../../../providers/my_list_provider.dart';
import '../../components/controls/download_button.dart';
import '../../components/ui/app_widgets.dart';
import '../../custom_controls/custom_controls_widget.dart';
import 'package:cineprime/video_js_bridge.dart';
import '../../../platform_utils.dart';
import '../payment/plans_list_page_mobile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieDetailsPage extends StatefulWidget {
  final BaseItem baseItem;

  const MovieDetailsPage(this.baseItem, {super.key});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  BetterPlayerController? _betterPlayerController;
  VideoJsController? _videoJsController;
  bool _playingMovie = true;
  bool _openingFullScreen = false;
  Duration _lastReported = Duration.zero;
  Timer? _positionTimer;
  bool _hasSeeked = false;
  int _detailTab = 0;
  bool _rated = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRating());
  }

  String _ratingKey(String userId) => 'cineprime_rated_${userId}_${widget.baseItem.id}';

  Future<void> _loadRating() async {
    final userId = Provider.of<AuthenticationProvider>(context, listen: false).getUser()?.id;
    if (userId == null || userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final rated = prefs.getBool(_ratingKey(userId)) ?? false;
    if (!mounted) return;
    setState(() => _rated = rated);
  }

  Future<void> _rateMovie() async {
    final userId = Provider.of<AuthenticationProvider>(context, listen: false).getUser()?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in to rate this title')));
      return;
    }
    final rated = !_rated;
    setState(() => _rated = rated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ratingKey(userId), rated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(rated ? 'Rated' : 'Rating removed')),
    );
  }

  void _initPlayer() {
    String videoUrl = widget.baseItem.videoUrl;
    if (videoUrl.isNotEmpty) {
      setState(() {
        PlatformUtils.isWeb ? _videoJsController = generateWebController(videoUrl) : _betterPlayerController = generateMobileController(videoUrl);
      });
      return;
    }

    Provider.of<ContentProvider>(context, listen: false).getVideoUrls(
      widget.baseItem.id,
      widget.baseItem.mediaType,
      parentId: "",
      () {
        videoUrl = widget.baseItem.videoUrl;
        setState(() {
          PlatformUtils.isWeb ? _videoJsController = generateWebController(videoUrl) : _betterPlayerController = generateMobileController(videoUrl);
        });
      },
    );
  }

  VideoJsController generateWebController(String videoUrl) {
    return VideoJsController(
      "video-$_playingMovie-${widget.baseItem.id}",
      videoJsOptions: VideoJsOptions(
        controls: true,
        loop: false,
        muted: false,
        poster: widget.baseItem.horizontalPosterUrl,
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

  BetterPlayerController generateMobileController(String url) {
    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: !widget.baseItem.getIsAdult(),
        showPlaceholderUntilPlay: true,
        looping: false,
        fullScreenAspectRatio: 16 / 9,
        deviceOrientationsOnFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableFullscreen: true,
          backgroundColor: Colors.transparent,
          controlBarColor: Colors.transparent,
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder: (controller, onControlsVisibilityChanged) => CustomControlsWidget(
            onControlsVisibilityChanged: onControlsVisibilityChanged,
            controlsConfiguration: BetterPlayerControlsConfiguration(),
            data: {
              "title": widget.baseItem.title,
              "genres": widget.baseItem.getClassificationString(),
              "bottom_title": widget.baseItem.getTitleHeaderString(),
              "age_rating": widget.baseItem.ageRating,
              "age_limit": widget.baseItem.ageLimit,
              "title_start": widget.baseItem.titleStart,
              "title_end": widget.baseItem.titleEnd,
            },
          ),
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

    void startTracking() {
      _positionTimer?.cancel();
      _lastReported = Duration.zero;

      _positionTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        if (!mounted) return;

        final videoController = controller.videoPlayerController;
        if (videoController == null) return;
        if (!videoController.value.initialized) return;

        Duration? position;
        try {
          position = await videoController.position;
        } catch (e) {
          debugPrint("⚠️ Failed to get position: $e");
          return;
        }

        if (position == null) return;

        if (position - _lastReported >= const Duration(seconds: 30)) {
          _lastReported = position;
          sendCurrentTimestamp(_lastReported);
        }
      });
    }

    void stopTracking() {
      _positionTimer?.cancel();
    }

    controller.videoPlayerController?.addListener(() async {
      final videoController = controller.videoPlayerController;
      if (videoController == null || _hasSeeked) return;

      if (videoController.value.initialized) {
        final totalDuration = videoController.value.duration ?? Duration.zero;
        final lastSeconds = widget.baseItem.lastTimestamp ?? 0;

        if (lastSeconds > 0 && lastSeconds < totalDuration.inSeconds) {
          _hasSeeked = true;
          await videoController.seekTo(Duration(seconds: lastSeconds));
          print("⏩ Seeking to $lastSeconds seconds");
        }
      }
    });

    controller.addEventsListener((event) async {
      if (!_playingMovie) return;

      Future<Duration?> safePosition() async {
        final videoController = controller.videoPlayerController;
        if (videoController == null || !videoController.value.initialized) return null;
        try {
          return await videoController.position;
        } catch (e) {
          debugPrint("⚠️ Failed to get position in event listener: $e");
          return null;
        }
      }

      // Handle play or pause
      if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen) {
        _openingFullScreen = false;
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.play || event.betterPlayerEventType == BetterPlayerEventType.pause) {
        final duration = await safePosition();
        if (duration != null) {
          sendCurrentTimestamp(duration);
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          startTracking();
        } else {
          stopTracking();
        }
      }

      // Handle finished
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        stopTracking();
        final duration = await safePosition();
        if (duration != null) {
          sendCurrentTimestamp(duration);
        }
      }

      // ✅ Handle seeking
      if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
        final duration = await safePosition();
        if (duration != null) {
          sendCurrentTimestamp(duration);
        }
      }
    });

    return controller;
  }

  void _playInLandscape() {
    if (!_playingMovie && widget.baseItem.videoUrl.isNotEmpty) {
      _switchPlayback(widget.baseItem.videoUrl, playingMovie: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _enterLandscapeAndPlay();
      });
      return;
    }
    _enterLandscapeAndPlay();
  }

  void _enterLandscapeAndPlay() {
    final controller = _betterPlayerController;
    if (controller == null) return;
    if (!controller.isFullScreen && !_openingFullScreen) {
      _openingFullScreen = true;
      controller.enterFullScreen();
    }
    controller.play();
  }

  void _switchPlayback(String url, {required bool playingMovie}) {
    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
    }
    setState(() {
      if (PlatformUtils.isWeb) {
        _videoJsController = generateWebController(url);
      } else {
        _betterPlayerController = generateMobileController(url);
      }
      _playingMovie = playingMovie;
    });
  }

  void sendCurrentTimestamp(Duration? duration) {
    if (!_playingMovie) return;
    if (duration == null) return;
    final seconds = duration.inSeconds;

    NetworkService().post(
      APIPath.continueWatching,
      {
        "timestamp": seconds,
        "content_id": widget.baseItem.id,
      },
      (data) {
        if (!context.mounted) return;
        Provider.of<ContentProvider>(context, listen: false).updateWatchTimestamp(widget.baseItem.id, seconds);
      },
      (error) {},
      () {},
    );
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final movie = contentProvider.getMediaById(
      widget.baseItem.id,
      widget.baseItem.mediaType,
    );
    final movies = contentProvider.getSuggestionMovies(movie!.suggestions);

    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final myList = Provider.of<MyListProvider>(context);
    bool isSubscribed = true;
    final isLoggedIn = authenticationProvider.getUser() != null;
    if (isLoggedIn) {
      isSubscribed = authenticationProvider.getUser()!.userSubscription != null;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      size: 40,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    CircleIconButton(
                      icon: myList.contains(movie.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 40,
                      iconColor: myList.contains(movie.id) ? AppColors.colorPrimary : Colors.white,
                      onPressed: () async {
                        final added = await myList.toggle(movie.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(added ? 'Added to My List' : 'Removed from My List')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: PlatformUtils.isWeb
                  ? _videoJsController != null
                      ? VideoJsWidget(
                          key: ValueKey(_videoJsController.hashCode),
                          videoJsController: _videoJsController!,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.baseItem.horizontalPosterUrl,
                          fit: BoxFit.cover,
                        )
                  : _betterPlayerController != null
                      ? BetterPlayer(
                          controller: _betterPlayerController!,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.baseItem.horizontalPosterUrl,
                          fit: BoxFit.cover,
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: AppTextStyles.displayTitle.copyWith(fontSize: 32)),
                  const SizedBox(height: 6),
                  Text(mediaMetaLine(movie), style: AppTextStyles.meta),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: !isSubscribed
                            ? GradientButton(
                                label: 'Subscribe',
                                icon: Icons.workspace_premium_rounded,
                                height: 48,
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => PlansListPage(),
                                  ));
                                },
                              )
                            : GradientButton(
                                label: 'Play',
                                icon: Icons.play_arrow_rounded,
                                height: 48,
                                onPressed: _playInLandscape,
                              ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () => myList.toggle(movie.id),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.colorSurface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.colorInputBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  myList.contains(movie.id) ? Icons.bookmark_rounded : Icons.add_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                const Flexible(
                                  child: Text(
                                    'My List',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!PlatformUtils.isWeb && movie.isDownloadable && movie.downloadUrl.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 4,
                          child: DownloadButton(baseItem: movie, inline: true),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (movie.trailerUrl.isNotEmpty)
                        DetailAction(
                          icon: Icons.movie_outlined,
                          label: 'Trailer',
                          onPressed: () {
                            setState(() => _detailTab = 2);
                            if (movie.trailerUrl.isNotEmpty && _playingMovie) {
                              _switchPlayback(movie.trailerUrl, playingMovie: false);
                            }
                          },
                        ),
                      DetailAction(
                        icon: _rated ? Icons.star_rounded : Icons.star_border_rounded,
                        label: 'Rate',
                        active: _rated,
                        onPressed: _rateMovie,
                      ),
                      DetailAction(
                        icon: Icons.ios_share_rounded,
                        label: 'Share',
                        onPressed: () {
                          Share.share(movie.title);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.colorTextSecondary, height: 1.45, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _tabLabel('About', 0),
                      const SizedBox(width: 22),
                      _tabLabel('More Like This', 1),
                      const SizedBox(width: 22),
                      _tabLabel('Trailers', 2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_detailTab == 0) _aboutBlock(movie),
                  if (_detailTab == 1)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double maxItemWidth = constraints.maxWidth > 600 ? 250 : 200;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            maxCrossAxisExtent: maxItemWidth,
                            childAspectRatio: 2 / 3,
                          ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            return MediaItem(baseItem: movies[index], replacement: true);
                          },
                        );
                      },
                    ),
                  if (_detailTab == 2 && movie.trailerUrl.isEmpty)
                    const Text('No trailers available', style: AppTextStyles.meta),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _tabLabel(String label, int index) {
    final selected = _detailTab == index;
    return GestureDetector(
      onTap: () => setState(() => _detailTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.colorTextMuted,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: selected ? 28 : 0,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutBlock(BaseItem movie) {
    String crew(String role) {
      final group = movie.castAndCrew?.firstWhere(
        (item) => item.role.toLowerCase() == role,
        orElse: () => CastAndCrew(role: '', members: []),
      );
      if (group == null || group.members.isEmpty) return 'N/A';
      return group.members.map((m) => m.name).join(', ');
    }

    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(label, style: const TextStyle(color: AppColors.colorTextMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('Director', crew('director')),
        row('Cast', crew('cast')),
        row('Language', 'Hindi'),
      ],
    );
  }
}
