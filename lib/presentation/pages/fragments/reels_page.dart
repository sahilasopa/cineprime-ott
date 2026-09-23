import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/models/media/reel_item.dart';
import 'package:cineprime/presentation/pages/media/movie_details_page.dart';
import 'package:cineprime/presentation/pages/media/tv_show_details_page.dart';
import 'package:cineprime/episode_player_stub.dart' if (dart.library.html) 'package:cineprime/presentation/pages/media/episode_player_page_web.dart';
import 'package:cineprime/presentation/pages/media/episode_player_page.dart';
import 'package:flutter/foundation.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/providers/reels_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

class ReelsPage extends StatefulWidget {
  final bool isActive;
  String? firstReelId;

  ReelsPage({super.key, required this.isActive, this.firstReelId});

  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  bool isMuted = false;
  bool isPreloaded = false;
  late ReelsProvider reelProvider;
  late ContentProvider contentProvider;
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _videoControllers.forEach((key, controller) {
      controller.dispose();
    });
    _videoControllers.clear();
  }

  void preloadVideos(List<ReelItem> reels) {
    final indexesToPreload = List.generate(6, (i) => currentIndex - 2 + i);
    bool updated = false;

    for (int index in indexesToPreload) {
      if (index >= 0 && index < reels.length) {
        final reel = reels[index];
        if (!_videoControllers.containsKey(reel.id)) {
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(reel.videoUrl),
          );

          controller.initialize().then((_) {
            controller.setLooping(true);
            controller.setVolume(isMuted ? 0 : 1);
            controller.pause();
            if (mounted && reels[currentIndex].id == reel.id) {
              setState(() {});
            }
            if (index == currentIndex && widget.isActive) {
              controller.play();
            }
          });

          _videoControllers[reel.id] = controller;
          updated = true;
        }
      }
    }

    // Remove controllers outside the preload window.
    final keysToRemove = _videoControllers.keys.where((miniId) {
      final index = reels.indexWhere((mini) => mini.id == miniId);
      return index < currentIndex - 2 || index > currentIndex + 3;
    }).toList();

    for (final key in keysToRemove) {
      _videoControllers[key]?.dispose();
      _videoControllers.remove(key);
      updated = true;
    }

    if (updated && mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant ReelsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        if (reelProvider.getReels().isNotEmpty) {
          final currentMini = reelProvider.getReels()[currentIndex];
          final controller = _videoControllers[currentMini.id];
          if (controller?.value.isInitialized ?? false) {
            controller!.play();
          }
        }
      } else {
        _videoControllers.forEach((key, controller) {
          if (controller.value.isInitialized) {
            controller.pause();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    reelProvider = Provider.of<ReelsProvider>(context);
    contentProvider = Provider.of<ContentProvider>(context);
    if (widget.firstReelId != null) {
      reelProvider.loadReels(
        clear: true,
        firstId: widget.firstReelId,
        onSuccess: () {
          preloadVideos(reelProvider.getReels());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              if (_pageController.page == 0) {
                _pageController.jumpToPage(
                  1,
                );
              }
              _pageController.animateToPage(
                0,
                duration: Duration(seconds: 2),
                curve: Curves.decelerate,
              );
            }
          });
          widget.firstReelId = null;
          isPreloaded = true;
        },
      );
    } else {
      if (!isPreloaded) {
        if (reelProvider.getReels().isNotEmpty) {
          isPreloaded = true;
          preloadVideos(
            reelProvider.getReels(),
          );
        }
      }
    }
    final minis = reelProvider.getReels();

    if (minis.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.pink,
        ),
      );
    }

    return CustomMaterialIndicator(
      onRefresh: () async {
        _videoControllers.forEach(
          (key, value) {
            value.dispose();
          },
        );
        _videoControllers.clear();
        await reelProvider.loadReels(clear: true);
        preloadVideos(reelProvider.getReels());
      },
      backgroundColor: Colors.white,
      indicatorBuilder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: CircularProgressIndicator(
            color: Colors.redAccent,
            value: controller.state.isLoading
                ? null
                : min(
                    controller.value,
                    1.0,
                  ),
          ),
        );
      },
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: minis.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
            final currentMini = minis[index];
            _videoControllers.forEach((key, controller) {
              if (key == currentMini.id && controller.value.isInitialized) {
                controller.play();
              } else {
                controller.pause();
              }
            });
            preloadVideos(minis);
          });

          if (index >= minis.length - 2) {
            reelProvider.loadReels();
          }
        },
        itemBuilder: (context, index) {
          final mini = minis[index];
          final controller = _videoControllers[mini.id];

          return GestureDetector(
            onTap: () {
              if (index == currentIndex &&
                  controller != null &&
                  controller.value.isInitialized) {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                controller != null && controller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                        color: Colors.yellow,
                      )),
                // Title overlay at the bottom left.
                Positioned(
                  bottom: 40,
                  left: 25,
                  child: Text(
                    mini.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(0, 0)),
                      ],
                    ),
                  ),
                ),
                // Buttons overlay on the right side.
                Positioned(
                  right: 10,
                  bottom: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isMuted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                isMuted = !isMuted;
                              });
                              if (controller == null) {
                                return;
                              }
                              if (!controller.value.isInitialized) {
                                return;
                              }
                              try {
                                controller.setVolume(isMuted ? 0 : 1);
                                for (final c in _videoControllers.values) {
                                  if (c.value.isInitialized) {
                                    c.setVolume(isMuted ? 0 : 1);
                                  }
                                }
                              } catch (e) {
                                // might be disposed
                              }
                            },
                          ),
                          const Text(
                            "Sound",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      if (mini.mediaId != null) const SizedBox(height: 24),
                      if (mini.mediaId != null)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.movie,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: () {
                                final controller = _videoControllers[mini.id];
                                if (controller != null &&
                                    controller.value.isInitialized) {
                                  controller.pause();
                                }
                                // Check if the mediaId matches any movie.
                                for (var movie in contentProvider.getMovies()) {
                                  if (movie.id == mini.mediaId) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MovieDetailsPage(
                                          contentProvider
                                              .getMovies()
                                              .firstWhere(
                                                (element) =>
                                                    element.id == mini.mediaId!,
                                              ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }

                                // Check if the mediaId matches any series.
                                for (var series
                                    in contentProvider.getSeries()) {
                                  if (series.id == mini.mediaId) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => TvShowDetailsPage(
                                          contentProvider
                                              .getSeries()
                                              .firstWhere(
                                                (element) =>
                                                    element.id == mini.mediaId!,
                                              ),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                }

                                // Check if the mediaId matches any episode in any series.
                                for (var series
                                    in contentProvider.getSeries()) {
                                  for (var episode in series.episodes) {
                                    if (episode.id == mini.mediaId) {
                                      // Use web player on web, native elsewhere
                                      final widget = kIsWeb
                                          ? EpisodePlayerPageWeb(episode)
                                          : EpisodePlayerPage(episode);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => widget,
                                        ),
                                      );
                                      return;
                                    }
                                  }
                                }

                                // Optionally, if no matching media is found, you could handle it here.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No matching media found.'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Play",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              Share.share(mini.shareText,
                                  subject: mini.shareSubject);
                            },
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Share",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (index == currentIndex &&
                    controller != null &&
                    controller.value.isInitialized)
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.black12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
