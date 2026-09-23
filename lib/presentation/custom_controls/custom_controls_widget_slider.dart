import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/pages/media/movie_details_page.dart';
import 'package:cineprime/presentation/pages/media/tv_show_details_page.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:river_player/src/configuration/better_player_controls_configuration.dart';
import 'package:river_player/src/controls/better_player_clickable_widget.dart';
import 'package:river_player/src/controls/better_player_controls_state.dart';
import 'package:river_player/src/core/better_player_controller.dart';
import 'package:river_player/src/video_player/video_player.dart';

class CustomControlsWidgetSlider extends StatefulWidget {
  final Function(bool visbility) onControlsVisibilityChanged;
  final BetterPlayerControlsConfiguration controlsConfiguration;
  final Map<String, dynamic> data;

  const CustomControlsWidgetSlider({
    super.key,
    required this.onControlsVisibilityChanged,
    required this.controlsConfiguration,
    required this.data,
  });

  @override
  State<StatefulWidget> createState() => _CustomControlsWidgetSliderState();
}

class _CustomControlsWidgetSliderState extends BetterPlayerControlsState<CustomControlsWidgetSlider> {
  VideoPlayerController? _controller;
  BetterPlayerController? _betterPlayerController;
  VideoPlayerValue? _latestValue;
  BaseItem? nextEpisode;
  bool _showSubscribeOverlay = false;

  BetterPlayerControlsConfiguration get _controlsConfiguration => widget.controlsConfiguration;

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 8,
            child: _buildTopLeftRated(),
          ),

          // Bottom-left: Play/Pause + More Info
          Positioned(
            bottom: 10,
            left: 5,
            child: Row(
              children: [_buildBottomLeftPlayPause(), _buildBottomRightMoreInfo()],
            ),
          ),

          // Bottom-right: Mute + Fullscreen
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              children: [
                _buildBottomRightMute(), // 👈 new position
                const SizedBox(width: 5),
                _buildBottomRightFullscreen(),
              ],
            ),
          ),
          if (_showSubscribeOverlay && (!widget.data['is_logged_in'] || !widget.data['is_subscribed'])) _buildSubscribeOverlay(context),
        ],
      ),
    );
  }

  Widget _buildSubscribeOverlay(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _showSubscribeOverlay = false);
      },
      child: Container(
        color: Colors.black.withOpacity(0.65), // dim background
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 42, color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              "To watch more",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (!widget.data['is_logged_in'] || !widget.data['is_subscribed']) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => PlansListPage(),
                  ));
                  return;
                }
              },
              child: const Text(
                "Subscribe Now",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRightMute() {
    final isMuted = (_latestValue?.volume ?? 0) == 0;
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        if (isMuted) {
          _betterPlayerController?.setVolume(0.5);
        } else {
          _betterPlayerController?.setVolume(0.0);
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          isMuted ? _controlsConfiguration.unMuteIcon : _controlsConfiguration.muteIcon,
          color: _controlsConfiguration.iconsColor,
          size: 22,
        ),
      ),
    );
  }

  // ----------------------------- UI COMPONENTS -----------------------------

  Widget _buildTopLeftRated() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Text(
        'Rated ${widget.data['rating']}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomLeftPlayPause() {
    final isPlaying = _betterPlayerController?.videoPlayerController?.value.isPlaying ?? false;

    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        if (isPlaying) {
          _betterPlayerController?.pause();
        } else {
          _betterPlayerController?.play();
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: _controlsConfiguration.iconsColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBottomRightFullscreen() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () async {
        _betterPlayerController?.toggleFullScreen();
        await Future.delayed(const Duration(milliseconds: 200));
        _betterPlayerController?.play();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(
          _betterPlayerController?.isFullScreen == true ? Icons.fullscreen_exit : Icons.fullscreen,
          color: _controlsConfiguration.iconsColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBottomRightMoreInfo() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () async {
        // ✅ Pause the video before navigating
        await _betterPlayerController?.pause();

        final isSeries = widget.data['is_series'] ?? false;
        final item = widget.data['item'];

        if (isSeries) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TvShowDetailsPage(item),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MovieDetailsPage(item),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 5),
            Text(
              "More Info",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------- CONTROLLER STATE -----------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final oldController = _betterPlayerController;
    _betterPlayerController = BetterPlayerController.of(context);
    final newVideoController = _betterPlayerController?.videoPlayerController;

    // 👇 detach old listener if controller changed
    if (oldController?.videoPlayerController != newVideoController) {
      _controller?.removeListener(_updateState);
      _controller = newVideoController;
      _controller?.addListener(_updateState);
    }
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {
      _latestValue = _controller?.value;

      final duration = _latestValue?.duration;
      final position = _latestValue?.position;

      if (duration != null && position != null && duration.inSeconds > 0 && position.inSeconds >= duration.inSeconds - 1) {
        if (!_showSubscribeOverlay) {
          _showSubscribeOverlay = true;
          _betterPlayerController?.pause();
          _betterPlayerController?.seekTo(Duration.zero);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_updateState);
    super.dispose();
  }

  // ----------------------------- REQUIRED OVERRIDES -----------------------------

  @override
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  @override
  BetterPlayerControlsConfiguration get betterPlayerControlsConfiguration => _controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  void cancelAndRestartTimer() {
    // No-op since controls are always visible
  }
}
