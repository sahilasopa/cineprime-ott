import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/pages/media/episode_details_page.dart';
import 'package:cineprime/episode_player_stub.dart' if (dart.library.html) 'package:cineprime/presentation/pages/media/episode_player_page_web.dart';
import 'package:cineprime/presentation/pages/media/episode_player_page.dart';
import 'package:flutter/foundation.dart';
import 'package:river_player/src/configuration/better_player_controls_configuration.dart';
import 'package:river_player/src/controls/better_player_clickable_widget.dart';
import 'package:river_player/src/controls/better_player_controls_state.dart';
import 'package:river_player/src/controls/better_player_material_progress_bar.dart';
import 'package:river_player/src/controls/better_player_multiple_gesture_detector.dart';
import 'package:river_player/src/controls/better_player_progress_colors.dart';
import 'package:river_player/src/core/better_player_controller.dart';
import 'package:river_player/src/core/better_player_utils.dart';
import 'package:river_player/src/video_player/video_player.dart';

class CustomControlsWidget extends StatefulWidget {
  ///Callback used to send information if player bar is hidden or not
  final Function(bool visbility) onControlsVisibilityChanged;

  ///Controls config
  final BetterPlayerControlsConfiguration controlsConfiguration;
  final Map<String, dynamic> data;

  const CustomControlsWidget({
    super.key,
    required this.onControlsVisibilityChanged,
    required this.controlsConfiguration,
    required this.data,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomControlsWidgetState();
  }
}

class _CustomControlsWidgetState extends BetterPlayerControlsState<CustomControlsWidget> {
  bool _showWarning = false;
  Timer? _warningTimer;
  bool _hasShownWarning = false;

  int? _skipStart;
  int? _skipEnd;

  VideoPlayerValue? _latestValue;
  bool _showNextEpisodeButton = false;
  bool _showSkipTitleButton = false;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _displayTapped = false;
  bool _wasLoading = false;
  VideoPlayerController? _controller;
  BetterPlayerController? _betterPlayerController;
  StreamSubscription? _controlsVisibilityStreamSubscription;
  BaseItem? nextEpisode;

  BetterPlayerControlsConfiguration get _controlsConfiguration => widget.controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  @override
  BetterPlayerControlsConfiguration get betterPlayerControlsConfiguration => _controlsConfiguration;

  @override
  Widget build(BuildContext context) {
    return buildLTRDirectionality(_buildMainWidget());
  }

  ///Builds main widget of the controls.
  Widget _buildMainWidget() {
    _wasLoading = isLoading(_latestValue);
    if (_latestValue?.hasError == true) {
      return Container(
        color: Colors.black,
        child: _buildErrorWidget(),
      );
    }
    return GestureDetector(
      onTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onTap?.call();
        }
        controlsNotVisible ? cancelAndRestartTimer() : changePlayerControlsNotVisible(true);
      },
      onDoubleTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onDoubleTap?.call();
        }
        cancelAndRestartTimer();
      },
      onLongPress: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onLongPress?.call();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AbsorbPointer(
            absorbing: controlsNotVisible,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_wasLoading) Center(child: _buildLoadingWidget()) else _buildHitArea(),
                if (_wasLoading)
                  Center(child: _buildLoadingWidget())
                else
                  AnimatedOpacity(
                    opacity: controlsNotVisible ? 0.0 : 1,
                    duration: _controlsConfiguration.controlsHideTime,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final buttonCount = 1 + (_controlsConfiguration.enableSkips ? 2 : 0);
                          final maxButtonWidth = (availableWidth / buttonCount).clamp(0.0, 80.0);
                          
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_controlsConfiguration.enableSkips)
                                SizedBox(
                                  width: maxButtonWidth,
                                  height: maxButtonWidth,
                                  child: _buildSkipButton(),
                                )
                              else
                                const SizedBox.shrink(),
                              SizedBox(
                                width: maxButtonWidth,
                                height: maxButtonWidth,
                                child: _buildReplayButton(_controller!),
                              ),
                              if (_controlsConfiguration.enableSkips)
                                SizedBox(
                                  width: maxButtonWidth,
                                  height: maxButtonWidth,
                                  child: _buildForwardButton(),
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
                Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
                _buildNextVideoWidget(),
                if (_showWarning)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildTopLeftWarning(),
                  ),
              ],
            ),
          ),
          if (_showNextEpisodeButton) _buildNextEpisodeButton(),
          _buildSkipTitleButton(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cacheSkipTimes();
    nextEpisode = widget.data['next_episode'];
  }

  void _dispose() {
    _controller?.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _warningTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
    _controlsVisibilityStreamSubscription?.cancel();
  }

  @override
  void didChangeDependencies() {
    final oldController = _betterPlayerController;
    _betterPlayerController = BetterPlayerController.of(context);
    _controller = _betterPlayerController!.videoPlayerController;
    _latestValue = _controller!.value;

    _cacheSkipTimes();

    if (oldController != _betterPlayerController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  void _cacheSkipTimes() {
    _skipStart = (widget.data['title_start'] as num?)?.toInt();
    _skipEnd = (widget.data['title_end'] as num?)?.toInt();
  }

  Widget _buildErrorWidget() {
    final errorBuilder = _betterPlayerController!.betterPlayerConfiguration.errorBuilder;
    if (errorBuilder != null) {
      return errorBuilder(context, _betterPlayerController!.videoPlayerController!.value.errorDescription);
    } else {
      final textStyle = TextStyle(color: _controlsConfiguration.textColor);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: _controlsConfiguration.iconsColor,
              size: 42,
            ),
            Text(
              _betterPlayerController!.translations.generalDefaultError,
              style: textStyle,
            ),
            if (_controlsConfiguration.enableRetry)
              TextButton(
                onPressed: () {
                  _betterPlayerController!.retryDataSource();
                },
                child: Text(
                  _betterPlayerController!.translations.generalRetry,
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
      );
    }
  }

  Widget _buildTopBar() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }

    return Container(
      child: (_controlsConfiguration.enableOverflowMenu)
          ? AnimatedOpacity(
              opacity: controlsNotVisible ? 0.0 : 1.0,
              duration: _controlsConfiguration.controlsHideTime,
              onEnd: _onPlayerHide,
              child: SizedBox(
                height: _controlsConfiguration.controlBarHeight + 12,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 👈 LEFT SIDE: Back button + Rating + Hello World
                    Positioned(
                      left: 12,
                      top: 6,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_betterPlayerController!.isFullScreen)
                            GestureDetector(
                              onTap: () => _betterPlayerController!.toggleFullScreen(),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAgeRatingBadge(),
                              const SizedBox(height: 2),
                              Text(
                                widget.data['genres'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    // 👈 CENTER: Title + Subtitle
                    if (_betterPlayerController!.isFullScreen)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.data['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(),

                    // 👈 RIGHT: PiP + More buttons
                    Positioned(
                      right: 8,
                      top: 4,
                      child: Row(
                        children: [
                          if (_controlsConfiguration.enablePip) _buildPipButtonWrapperWidget(controlsNotVisible, _onPlayerHide),
                          _buildMoreButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildPipButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        betterPlayerController!.enablePictureInPicture(betterPlayerController!.betterPlayerGlobalKey!);
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          betterPlayerControlsConfiguration.pipMenuIcon,
          color: betterPlayerControlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildPipButtonWrapperWidget(bool hideStuff, void Function() onPlayerHide) {
    return FutureBuilder<bool>(
      future: betterPlayerController!.isPictureInPictureSupported(),
      builder: (context, snapshot) {
        final bool isPipSupported = snapshot.data ?? false;
        if (isPipSupported && _betterPlayerController!.betterPlayerGlobalKey != null) {
          return AnimatedOpacity(
            opacity: hideStuff ? 0.0 : 1.0,
            duration: betterPlayerControlsConfiguration.controlsHideTime,
            onEnd: onPlayerHide,
            child: SizedBox(
              height: betterPlayerControlsConfiguration.controlBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildPipButton(),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildAgeRatingBadge() {
    final age = widget.data['age_rating'] ?? '';
    if (age.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black54,
      ),
      child: Text(
        'Rated $age',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        onShowMoreClicked();
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          _controlsConfiguration.overflowMenuIcon,
          color: _controlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    return AnimatedOpacity(
      opacity: controlsNotVisible ? 0.0 : 1.0,
      duration: _controlsConfiguration.controlsHideTime,
      onEnd: _onPlayerHide,
      child: Container(
        height: _controlsConfiguration.controlBarHeight + 20.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 75,
              child: Row(
                children: [
                  if (_controlsConfiguration.enablePlayPause) _buildPlayPause(_controller!) else const SizedBox(),
                  if (_betterPlayerController!.isLiveStream()) _buildLiveWidget() else _controlsConfiguration.enableProgressText ? Expanded(child: _buildPosition()) : const SizedBox(),
                  const Spacer(),
                  if (_controlsConfiguration.enableMute) _buildMuteButton(_controller) else const SizedBox(),
                  if (_controlsConfiguration.enableFullscreen) _buildExpandButton() else const SizedBox(),
                ],
              ),
            ),
            if (_betterPlayerController!.isLiveStream()) const SizedBox() else _controlsConfiguration.enableProgressBar ? _buildProgressBar() : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveWidget() {
    return Text(
      _betterPlayerController!.translations.controlsLive,
      style: TextStyle(color: _controlsConfiguration.liveTextColor, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildExpandButton() {
    return Padding(
      padding: EdgeInsets.only(right: 12.0),
      child: BetterPlayerMaterialClickableWidget(
        onTap: _onExpandCollapse,
        child: AnimatedOpacity(
          opacity: controlsNotVisible ? 0.0 : 1.0,
          duration: _controlsConfiguration.controlsHideTime,
          child: Container(
            height: _controlsConfiguration.controlBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Icon(
                _betterPlayerController!.isFullScreen ? _controlsConfiguration.fullscreenDisableIcon : _controlsConfiguration.fullscreenEnableIcon,
                color: _controlsConfiguration.iconsColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    return Center(
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 0.1,
        duration: _controlsConfiguration.controlsHideTime,
        child: _buildMiddleRow(),
      ),
    );
  }

  Widget _buildMiddleRow() {
    return Container(
      color: _controlsConfiguration.controlBarColor,
      width: double.infinity,
      height: double.infinity,
      child: _betterPlayerController?.isLiveStream() == true ? const SizedBox() : Container(),
    );
  }

  Widget _buildHitAreaClickableButton({Widget? icon, required void Function() onClicked}) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 80.0, maxWidth: 80.0),
      child: BetterPlayerMaterialClickableWidget(
        onTap: onClicked,
        child: Align(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                children: [icon!],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        _controlsConfiguration.skipBackIcon,
        size: 30,
        color: _controlsConfiguration.iconsColor,
      ),
      onClicked: skipBack,
    );
  }

  Widget _buildForwardButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        _controlsConfiguration.skipForwardIcon,
        size: 30,
        color: _controlsConfiguration.iconsColor,
      ),
      onClicked: skipForward,
    );
  }

  Widget _buildTopLeftWarning() {
    if (!controlsNotVisible) return Container();
    return AnimatedSlide(
      offset: _showWarning ? const Offset(0, 0) : const Offset(-1.2, 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _showWarning ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Yellow vertical bar spanning full height of text block
              Container(
                width: 4,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD200),
                ),
              ),
              // Text content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rated: ${widget.data['age_rating']} ${widget.data['age_limit']}+',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mature Content',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplayButton(VideoPlayerController controller) {
    final bool isFinished = isVideoFinished(_latestValue);
    return _buildHitAreaClickableButton(
      icon: isFinished
          ? Icon(
              Icons.replay,
              size: 42,
              color: _controlsConfiguration.iconsColor,
            )
          : Icon(
              controller.value.isPlaying ? _controlsConfiguration.pauseIcon : _controlsConfiguration.playIcon,
              size: 42,
              color: _controlsConfiguration.iconsColor,
            ),
      onClicked: () {
        if (isFinished) {
          if (_latestValue != null && _latestValue!.isPlaying) {
            if (_displayTapped) {
              changePlayerControlsNotVisible(true);
            } else {
              cancelAndRestartTimer();
            }
          } else {
            _onPlayPause();
            changePlayerControlsNotVisible(true);
          }
        } else {
          _onPlayPause();
        }
      },
    );
  }

  Widget _buildNextVideoWidget() {
    return StreamBuilder<int?>(
      stream: _betterPlayerController!.nextVideoTimeStream,
      builder: (context, snapshot) {
        final time = snapshot.data;
        if (time != null && time > 0) {
          return BetterPlayerMaterialClickableWidget(
            onTap: () {
              _betterPlayerController!.playNextVideo();
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(bottom: _controlsConfiguration.controlBarHeight + 20, right: 24),
                decoration: BoxDecoration(
                  color: _controlsConfiguration.controlBarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${_betterPlayerController!.translations.controlsNextVideoIn} $time...",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildMuteButton(
    VideoPlayerController? controller,
  ) {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        cancelAndRestartTimer();
        if (_latestValue!.volume == 0) {
          _betterPlayerController!.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller!.value.volume;
          _betterPlayerController!.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRect(
          child: Container(
            height: _controlsConfiguration.controlBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              (_latestValue != null && _latestValue!.volume > 0) ? _controlsConfiguration.muteIcon : _controlsConfiguration.unMuteIcon,
              color: _controlsConfiguration.iconsColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPause(VideoPlayerController controller) {
    return BetterPlayerMaterialClickableWidget(
      key: const Key("better_player_material_controls_play_pause_button"),
      onTap: _onPlayPause,
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          controller.value.isPlaying ? _controlsConfiguration.pauseIcon : _controlsConfiguration.playIcon,
          color: _controlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildPosition() {
    final position = _latestValue != null ? _latestValue!.position : Duration.zero;
    final duration = _latestValue != null && _latestValue!.duration != null ? _latestValue!.duration! : Duration.zero;

    return Padding(
      padding: _controlsConfiguration.enablePlayPause ? const EdgeInsets.only(right: 24) : const EdgeInsets.symmetric(horizontal: 22),
      child: RichText(
        text: TextSpan(
            text: BetterPlayerUtils.formatDuration(position),
            style: TextStyle(
              fontSize: 10.0,
              color: _controlsConfiguration.textColor,
              decoration: TextDecoration.none,
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' / ${BetterPlayerUtils.formatDuration(duration)}',
                style: TextStyle(
                  fontSize: 10.0,
                  color: _controlsConfiguration.textColor,
                  decoration: TextDecoration.none,
                ),
              )
            ]),
      ),
    );
  }

  @override
  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    changePlayerControlsNotVisible(false);
    if (!_hasShownWarning) {
      _warningTimer?.cancel();
      _warningTimer = Timer(const Duration(seconds: 5), () {
        if (controlsNotVisible && mounted) {
          setState(() {
            _showWarning = true;
            _hasShownWarning = true;
          });

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWarning = false;
              });
            }
          });
        }
      });
    }

    _displayTapped = true;
  }

  Future<void> _initialize() async {
    _controller!.addListener(_updateState);
    _hasShownWarning = false;
    _showWarning = false;
    _updateState();

    if (!_hasShownWarning) {
      _warningTimer?.cancel();
      _warningTimer = Timer(const Duration(seconds: 5), () {
        if (controlsNotVisible && mounted) {
          setState(() {
            _showWarning = true;
            _hasShownWarning = true;
          });

          // Auto-hide after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWarning = false;
              });
            }
          });
        }
      });
    }

    if ((_controller!.value.isPlaying) || _betterPlayerController!.betterPlayerConfiguration.autoPlay) {
      _startHideTimer();
    }

    if (_controlsConfiguration.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        changePlayerControlsNotVisible(false);
      });
    }

    _controlsVisibilityStreamSubscription = _betterPlayerController!.controlsVisibilityStream.listen((state) {
      changePlayerControlsNotVisible(!state);
      if (!controlsNotVisible) {
        cancelAndRestartTimer();
      }
    });
  }

  void _onExpandCollapse() {
    changePlayerControlsNotVisible(true);
    _betterPlayerController!.toggleFullScreen();
    _showAfterExpandCollapseTimer = Timer(_controlsConfiguration.controlsHideTime, () {
      setState(() {
        cancelAndRestartTimer();
      });
    });
  }

  void _onPlayPause() {
    bool isFinished = false;

    if (_latestValue?.position != null && _latestValue?.duration != null) {
      isFinished = _latestValue!.position >= _latestValue!.duration!;
    }

    if (_controller!.value.isPlaying) {
      changePlayerControlsNotVisible(false);
      _hideTimer?.cancel();
      _betterPlayerController!.pause();
    } else {
      cancelAndRestartTimer();

      if (!_controller!.value.initialized) {
      } else {
        if (isFinished) {
          _betterPlayerController!.seekTo(const Duration());
        }
        _betterPlayerController!.play();
        _betterPlayerController!.cancelNextVideoTimer();
      }
    }
  }

  void _startHideTimer() {
    if (_betterPlayerController!.controlsAlwaysVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(milliseconds: 3000), () {
      changePlayerControlsNotVisible(true);
    });
  }

  void _updateState() async {
    if (!mounted) return;

    final value = _controller?.value;
    if (value == null) return;

    final duration = value.duration;
    final position = value.position;
    final posSec = position.inSeconds;

    if (duration != null) {
      final timeRemaining = duration - position;

      // Show button when 60 seconds or less remain
      if (timeRemaining.inSeconds <= 60 && !_showNextEpisodeButton) {
        setState(() {
          _showNextEpisodeButton = true;
        });
      } else if (timeRemaining.inSeconds > 60 && _showNextEpisodeButton) {
        setState(() {
          _showNextEpisodeButton = false;
        });
      }
      if (timeRemaining.inSeconds == 0) {
        if (nextEpisode != null) {
          if (_betterPlayerController?.isFullScreen == true) {
            _betterPlayerController!.exitFullScreen();
            await Future.delayed(const Duration(milliseconds: 300));
          }

          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => EpisodeDetailsPage(nextEpisode!),
            ));
          }
        }
      }

      if (_skipStart != null && _skipEnd != null && posSec >= _skipStart! && posSec <= _skipEnd!) {
        setState(() {
          _showSkipTitleButton = true;
        });
      } else {
        setState(() {
          _showSkipTitleButton = false;
        });
      }
    }

    // Your existing update logic
    if (!controlsNotVisible || isVideoFinished(value) || _wasLoading || isLoading(value)) {
      setState(() {
        _latestValue = value;
        if (isVideoFinished(_latestValue) && _betterPlayerController?.isLiveStream() == false) {
          changePlayerControlsNotVisible(false);
        }
      });
    }
  }

  Widget _buildNextEpisodeButton() {
    if (nextEpisode == null) return const SizedBox();
    if (!_showNextEpisodeButton) return const SizedBox();
    if (!controlsNotVisible) return const SizedBox();

    // Nudge it a bit farther right and use a smaller bottom offset in full-screen
    final isFs = _betterPlayerController?.isFullScreen ?? false;
    final double bottom = isFs ? 40 : 40; // closer to edge when full-screen
    const double right = 12; // “little more towards right”

    return Positioned(
      bottom: bottom,
      right: right,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          // white pill
          foregroundColor: Colors.black,
          // icon / text colour
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // “square rounded”
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text(
          'Next Episode',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          if (nextEpisode == null) return;

          if (_betterPlayerController?.isFullScreen == true) {
            _betterPlayerController!.exitFullScreen();
            await Future.delayed(const Duration(milliseconds: 300));
          }

          if (mounted) {
            // Use web player on web, native elsewhere
            final widget = kIsWeb
                ? EpisodePlayerPageWeb(nextEpisode!)
                : EpisodePlayerPage(nextEpisode!);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => widget,
            ));
          }
        },
      ),
    );
  }

  Widget _buildSkipTitleButton() {
    if (!_showSkipTitleButton) return const SizedBox();
    if (!controlsNotVisible) return const SizedBox();
    final isFs = _betterPlayerController?.isFullScreen ?? false;
    final double bottom = isFs ? 40 : 40; // closer to edge when full-screen
    const double right = 12; // “little more towards right”

    return Positioned(
      bottom: bottom,
      right: right,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          // white pill
          foregroundColor: Colors.black,
          // icon / text colour
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // “square rounded”
          ),
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text(
          'Skip Title',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          _betterPlayerController?.seekTo(Duration(seconds: _skipEnd!.toInt()));
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      flex: 40,
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BetterPlayerMaterialVideoProgressBar(
          _controller,
          _betterPlayerController,
          onDragStart: () {
            _hideTimer?.cancel();
          },
          onDragEnd: () {
            _startHideTimer();
          },
          onTapDown: () {
            cancelAndRestartTimer();
          },
          colors: BetterPlayerProgressColors(
              playedColor: _controlsConfiguration.progressBarPlayedColor,
              handleColor: _controlsConfiguration.progressBarHandleColor,
              bufferedColor: _controlsConfiguration.progressBarBufferedColor,
              backgroundColor: _controlsConfiguration.progressBarBackgroundColor),
        ),
      ),
    );
  }

  void _onPlayerHide() {
    _betterPlayerController!.toggleControlsVisibility(!controlsNotVisible);
    widget.onControlsVisibilityChanged(!controlsNotVisible);
  }

  Widget? _buildLoadingWidget() {
    if (_controlsConfiguration.loadingWidget != null) {
      return Container(
        color: _controlsConfiguration.controlBarColor,
        child: _controlsConfiguration.loadingWidget,
      );
    }

    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(_controlsConfiguration.loadingColor),
    );
  }
}
