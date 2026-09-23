import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/video_js_bridge.dart';
import 'package:provider/provider.dart';

class EpisodePlayerPageWeb extends StatefulWidget {
  final BaseItem baseItem;

  const EpisodePlayerPageWeb(this.baseItem, {Key? key}) : super(key: key);

  @override
  State<EpisodePlayerPageWeb> createState() => _EpisodePlayerPageWebState();
}

class _EpisodePlayerPageWebState extends State<EpisodePlayerPageWeb> {
  VideoJsController? _videoJsController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
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
      _videoJsController = VideoJsController(
        widget.baseItem.id,
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
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_videoJsController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
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
      body: SafeArea(
        child: VideoJsWidget(
          videoJsController: _videoJsController!,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}

