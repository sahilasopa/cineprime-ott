import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/custom_controls/custom_controls_widget.dart';
import 'package:river_player/river_player.dart';

class TrailerVideoPlayer extends StatefulWidget {
  final BaseItem baseItem;

  const TrailerVideoPlayer(this.baseItem, {super.key});

  @override
  State<TrailerVideoPlayer> createState() => _TrailerVideoPlayerState();
}

class _TrailerVideoPlayerState extends State<TrailerVideoPlayer> {
  BetterPlayerController? _betterPlayerController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    if (widget.baseItem.trailerUrl.isNotEmpty) {
      _setupController(widget.baseItem.trailerUrl);
      return;
    }
    
    setState(() {
      _isLoading = false;
    });
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _betterPlayerController?.removeEventsListener((event) {});
    _betterPlayerController?.dispose();
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
            },
          ),
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        filePath,
      ),
    );

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
