import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/presentation/custom_controls/custom_controls_widget.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:river_player/river_player.dart';

class EpisodePlayerPage extends StatefulWidget {
  final BaseItem baseItem;

  const EpisodePlayerPage(this.baseItem, {super.key});

  @override
  State<EpisodePlayerPage> createState() => _EpisodePlayerPageState();
}

class _EpisodePlayerPageState extends State<EpisodePlayerPage> {
  BetterPlayerController? _betterPlayerController;
  bool _isLoading = true;
  List<BaseItem> episodeList = [];
  Duration _lastReported = Duration.zero;
  Timer? _positionTimer;
  bool _hasSeeked = false;
  bool _isDisposed = false;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _initEpisodeList();
    _initPlayer();
  }

  void _initEpisodeList() {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    episodeList.clear();
    try {
      final parentItem = contentProvider.getSeries().firstWhere(
        (element) => element.id == widget.baseItem.parentSeriesId,
      );
      episodeList.addAll(parentItem.episodes.where(
        (episode) =>
            (episode.seasonNumber > widget.baseItem.seasonNumber) ||
            (episode.seasonNumber == widget.baseItem.seasonNumber &&
                episode.episodeNumber > widget.baseItem.episodeNumber),
      ));
    } catch (e) {
      // Parent series not found, episodeList remains empty
    }
  }

  void sendCurrentTimestamp(Duration? duration) {
    // Comprehensive guards to prevent crashes
    if (_isDisposed || !mounted || duration == null) return;
    
    try {
      final seconds = duration.inSeconds;
      
      // Validate timestamp values
      if (seconds < 0) return;
      if (seconds > 86400) return; // Max 24 hours, likely invalid
      
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      final contentId = widget.baseItem.id;
      
      if (contentId.isEmpty) return;

      NetworkService().post(
        APIPath.continueWatching,
        {
          "timestamp": seconds,
          "content_id": contentId,
        },
        (data) {
          if (!_isDisposed && mounted) {
            try {
              contentProvider.updateWatchTimestamp(contentId, seconds);
            } catch (e) {
              debugPrint("⚠️ Failed to update watch timestamp: $e");
            }
          }
        },
        (error) {
          debugPrint("⚠️ Failed to send timestamp: $error");
        },
        () {},
      );
    } catch (e) {
      debugPrint("⚠️ Error in sendCurrentTimestamp: $e");
    }
  }

  void _initPlayer() {
    if (widget.baseItem.videoUrl.isNotEmpty) {
      _setupController(widget.baseItem.videoUrl);
      return;
    }
    
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    contentProvider.getVideoUrls(
      widget.baseItem.id,
      widget.baseItem.mediaType,
      parentId: widget.baseItem.parentSeriesId,
      () {
        if (mounted) {
          _setupController(widget.baseItem.videoUrl);
        }
      },
    );
  }

  void _setupController(String videoUrl) {
    if (videoUrl.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _betterPlayerController = generateController(videoUrl);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Safely cancel timer
    try {
      _positionTimer?.cancel();
      _positionTimer = null;
    } catch (e) {
      debugPrint("⚠️ Error canceling timer: $e");
    }
    
    // Safely remove event listeners and dispose controller
    try {
      _betterPlayerController?.removeEventsListener((event) {});
    } catch (e) {
      debugPrint("⚠️ Error removing event listener: $e");
    }
    
    try {
      _betterPlayerController?.dispose();
      _betterPlayerController = null;
    } catch (e) {
      debugPrint("⚠️ Error disposing controller: $e");
    }
    
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint("⚠️ Error resetting system UI: $e");
    }
    
    super.dispose();
  }

  BetterPlayerController generateController(String filePath) {
    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 9 / 16,
        fit: BoxFit.contain,
        autoPlay: true,
        looping: false,
        fullScreenAspectRatio: 9 / 16,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableFullscreen: true,
          backgroundColor: Colors.black,
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
        filePath,
      ),
    );

    void startTracking() {
      if (_isDisposed || _isTracking) return;
      
      try {
        _positionTimer?.cancel();
        _lastReported = Duration.zero;
        _isTracking = true;

        _positionTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
          // Multiple guards to prevent crashes
          if (_isDisposed || !mounted) {
            _positionTimer?.cancel();
            _isTracking = false;
            return;
          }
          
          try {
            final videoController = controller.videoPlayerController;
            if (videoController == null) return;
            
            // Check if controller is still valid and initialized
            if (!videoController.value.initialized) return;
            if (videoController.value.hasError) return;
            
            Duration? position;
            try {
              // Add timeout to prevent hanging
              position = await videoController.position.timeout(
                const Duration(seconds: 2),
              );
            } on TimeoutException {
              debugPrint("⚠️ Position request timed out");
              return;
            } catch (e) {
              debugPrint("⚠️ Failed to get position: $e");
              return;
            }

            if (position == null) return;
            
            // Validate position is reasonable
            if (position.inSeconds < 0) return;
            if (position.inSeconds > 86400) return; // Max 24 hours

            // Only send if significant progress made (30 seconds)
            if (position - _lastReported >= const Duration(seconds: 30)) {
              _lastReported = position;
              sendCurrentTimestamp(_lastReported);
            }
          } catch (e) {
            debugPrint("⚠️ Error in tracking timer: $e");
            // Don't cancel timer on single error, but log it
          }
        });
      } catch (e) {
        debugPrint("⚠️ Error starting tracking: $e");
        _isTracking = false;
      }
    }

    void stopTracking() {
      try {
        _positionTimer?.cancel();
        _isTracking = false;
      } catch (e) {
        debugPrint("⚠️ Error stopping tracking: $e");
      }
    }

    controller.videoPlayerController?.addListener(() async {
      // Guards to prevent crashes during seek
      if (_isDisposed || !mounted || _hasSeeked) return;
      
      try {
        final videoController = controller.videoPlayerController;
        if (videoController == null) return;
        
        // Check if controller is still valid
        if (!videoController.value.initialized) return;
        if (videoController.value.hasError) return;

        final totalDuration = videoController.value.duration;
        if (totalDuration == null || totalDuration == Duration.zero) return;
        
        final lastSeconds = widget.baseItem.lastTimestamp ?? 0;
        
        // Validate seek position
        if (lastSeconds <= 0) return;
        if (lastSeconds >= totalDuration.inSeconds) return;
        if (lastSeconds > 86400) return; // Max 24 hours, likely invalid

        _hasSeeked = true;
        
        try {
          // Add timeout to prevent hanging on seek
          await videoController.seekTo(Duration(seconds: lastSeconds)).timeout(
            const Duration(seconds: 5),
          );
          debugPrint("⏩ Seeking to $lastSeconds seconds");
        } on TimeoutException {
          debugPrint("⚠️ Seek operation timed out");
          // Reset flag so we can try again if needed
          _hasSeeked = false;
        } catch (e) {
          debugPrint("⚠️ Failed to seek: $e");
          // Reset flag so we can try again if needed
          _hasSeeked = false;
        }
      } catch (e) {
        debugPrint("⚠️ Error in video controller listener: $e");
      }
    });

    controller.addEventsListener((event) async {
      // Guards to prevent crashes in event listener
      if (_isDisposed || !mounted) return;
      
      try {
        Duration? duration;
        
        // Safely get position with timeout and error handling
        try {
          final videoController = controller.videoPlayerController;
          if (videoController != null && 
              videoController.value.initialized && 
              !videoController.value.hasError) {
            duration = await videoController.position.timeout(
              const Duration(seconds: 2),
            );
          }
        } on TimeoutException {
          debugPrint("⚠️ Position request timed out in event listener");
          duration = null;
        } catch (e) {
          debugPrint("⚠️ Failed to get position in event listener: $e");
          duration = null;
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.play || 
            event.betterPlayerEventType == BetterPlayerEventType.pause) {
          if (duration != null) {
            sendCurrentTimestamp(duration);
          }
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            startTracking();
          } else {
            stopTracking();
          }
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          stopTracking();
          if (duration != null) {
            sendCurrentTimestamp(duration);
          }
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.seekTo) {
          if (duration != null) {
            sendCurrentTimestamp(duration);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Error in event listener: $e");
      }
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_betterPlayerController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Unable to load video",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: BetterPlayer(
                  controller: _betterPlayerController!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

