import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/components/media/episode_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';

import '../../components/controls/expandable_text.dart';
import '../../custom_controls/custom_controls_widget.dart';
import 'package:cineprime/video_js_bridge.dart';

class EpisodeDetailsPage extends StatefulWidget {
  final BaseItem baseItem;

  const EpisodeDetailsPage(this.baseItem, {super.key});

  @override
  State<EpisodeDetailsPage> createState() => _EpisodeDetailsPageState();
}

class _EpisodeDetailsPageState extends State<EpisodeDetailsPage> {
  BetterPlayerController? _betterPlayerController;
  VideoJsController? _videoJsController;
  List<BaseItem> episodeList = [];
  Duration _lastReported = Duration.zero;
  Timer? _positionTimer;
  bool _hasSeeked = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();

    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    episodeList.clear();
    final parentItem = contentProvider.getSeries().firstWhere((element) => element.id == widget.baseItem.parentSeriesId);
    episodeList.addAll(parentItem.episodes
        .where((episode) => (episode.seasonNumber > widget.baseItem.seasonNumber) || (episode.seasonNumber == widget.baseItem.seasonNumber && episode.episodeNumber > widget.baseItem.episodeNumber)));
  }

  void sendCurrentTimestamp(Duration? duration) {
    if (!mounted || duration == null) return;
    final seconds = duration.inSeconds;
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    final contentId = widget.baseItem.id;

    NetworkService().post(
      APIPath.continueWatching,
      {
        "timestamp": seconds,
        "content_id": contentId,
      },
      (data) {
        if (!mounted) return;
        contentProvider.updateWatchTimestamp(contentId, seconds);
      },
      (error) {},
      () {},
    );
  }

  void _initPlayer() {
    if (widget.baseItem.videoUrl.isNotEmpty) {
      setState(() {
        PlatformUtils.isWeb ? _videoJsController = generateWebController(widget.baseItem.videoUrl) : _betterPlayerController = generateMobileController(widget.baseItem.videoUrl);
      });
      return;
    }
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    contentProvider.getVideoUrls(widget.baseItem.id, widget.baseItem.mediaType, parentId: widget.baseItem.parentSeriesId, () {
      setState(() {
        PlatformUtils.isWeb ? _videoJsController = generateWebController(widget.baseItem.videoUrl) : _betterPlayerController = generateMobileController(widget.baseItem.videoUrl);
      });
    });
  }

  VideoJsController generateWebController(String videoUrl) {
    return VideoJsController(
      "video-${widget.baseItem.id}",
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
        looping: false,
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
              "next_episode": episodeList.firstOrNull,
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
      Duration? duration;
      final videoController = controller.videoPlayerController;
      if (videoController != null && videoController.value.initialized) {
        try {
          duration = await videoController.position;
        } catch (e) {
          debugPrint("⚠️ Failed to get position in event listener: $e");
        }
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.play || event.betterPlayerEventType == BetterPlayerEventType.pause) {
        if (duration != null) sendCurrentTimestamp(duration);
        event.betterPlayerEventType == BetterPlayerEventType.play ? startTracking() : stopTracking();
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        stopTracking();
        if (duration != null) sendCurrentTimestamp(duration);
      }

      if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
        if (duration != null) sendCurrentTimestamp(duration);
      }
    });

    return controller;
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Watch Episode",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: PlatformUtils.isWeb
                    ? _videoJsController != null
                        ? VideoJsWidget(
                            videoJsController: _videoJsController!,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.baseItem.horizontalPosterUrl,
                          )
                    : _betterPlayerController != null
                        ? BetterPlayer(
                            controller: _betterPlayerController!,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.baseItem.horizontalPosterUrl,
                          ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 15),
                child: Text(
                  widget.baseItem.title,
                  style: const TextStyle(color: AppColors.colorPrimary, fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 0),
                child: Text(
                  "Season ${widget.baseItem.seasonNumber} Episode ${widget.baseItem.episodeNumber}",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 8, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpandableTextWidget(
                      text: widget.baseItem.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 10, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Episodes:",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 21),
                    ),
                  ],
                ),
              ),
              if (episodeList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: episodeList.length,
                    itemBuilder: (context, index) {
                      return EpisodeItem(baseItem: episodeList[index]);
                    },
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Center(
                    child: Text(
                      "Congratulations, you've seen all the available episodes, more episodes might be coming soon",
                      style: TextStyle(color: Colors.white60, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
      ),
    );
  }
}
