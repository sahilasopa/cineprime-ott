import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/models/user/user.dart';
import 'package:cineprime/presentation/custom_controls/custom_controls_widget_slider.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:river_player/river_player.dart';

class CarouselHeroItem extends StatefulWidget {
  final dynamic slide;
  final User? user;
  final double aspectRatio;
  final bool isActive;
  final VoidCallback onTap;

  const CarouselHeroItem({
    super.key,
    required this.slide,
    required this.user,
    required this.aspectRatio,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<CarouselHeroItem> createState() => CarouselHeroItemState();
}

class CarouselHeroItemState extends State<CarouselHeroItem> {
  BetterPlayerController? _bp;

  bool get _wantsTrailer {
    final s = widget.slide;
    final url = (s.trailerUrl ?? '').toString();
    return (s.autoPlayTrailer == true) && url.isNotEmpty;
  }

  void pause() {
    _bp?.pause();
  }

  void _ensureController() {
    if (_bp != null || !_wantsTrailer) return;
    final ds = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.slide.trailerUrl,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 30000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );

    _bp = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        fit: BoxFit.cover,
        aspectRatio: 16 / 9,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlayPause: false,
          enableProgressBar: false,
          enableProgressText: false,
          enableSkips: false,
          enableMute: false,
          enableFullscreen: false,
          enableAudioTracks: false,
          enablePlaybackSpeed: false,
          enableSubtitles: false,
          playerTheme: BetterPlayerTheme.custom,
          customControlsBuilder: (controller, onControlsVisibilityChanged) => CustomControlsWidgetSlider(
            onControlsVisibilityChanged: onControlsVisibilityChanged,
            controlsConfiguration: const BetterPlayerControlsConfiguration(),
            data: {
              'rating': widget.slide.ageRating ?? '',
              'is_series': widget.slide.mediaType == MediaType.series,
              'item': widget.slide,
              'is_logged_in': widget.user != null,
              'is_subscribed': widget.user != null && widget.user!.userSubscription != null,
            },
          ),
        ),
        handleLifecycle: true,
      ),
      betterPlayerDataSource: ds,
    );

    _bp!.setVolume(0.0);
  }

  void _applyActiveState() {
    if (!_wantsTrailer || _bp == null) return;
    if (widget.isActive) {
      _bp!.play();
    } else {
      _bp!.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_wantsTrailer) {
      _ensureController();
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyActiveState());
    }
  }

  void _togglePlayPause() {
    if (_bp == null) return;
    final isPlaying = _bp!.isPlaying() ?? false;
    if (isPlaying) {
      _bp!.pause();
    } else {
      _bp!.play();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(CarouselHeroItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_wantsTrailer && _bp == null) {
      _ensureController();
    }
    if (oldWidget.isActive != widget.isActive) {
      _applyActiveState();
    }
  }

  @override
  void dispose() {
    _bp?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _wantsTrailer && _bp != null
        ? AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayPause,
              child: BetterPlayer(controller: _bp!),
            ),
          )
        : AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: CachedNetworkImage(
                imageUrl: widget.slide.getFeaturedPosterUrl(),
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 200,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 200,
                    ),
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),
          );

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (!_wantsTrailer)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          if (!_wantsTrailer)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                              SizedBox(width: 4),
                              Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleIconButton(
                        icon: Icons.add,
                        size: 40,
                        background: Colors.white.withValues(alpha: 0.12),
                        onPressed: widget.onTap,
                      ),
                    ],
                  ),
            ),
        ],
      ),
    );
  }
}
