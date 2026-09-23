import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/video_js_bridge.dart';

class TrailerVideoPlayerWeb extends StatefulWidget {
  final BaseItem baseItem;

  const TrailerVideoPlayerWeb(this.baseItem, {Key? key}) : super(key: key);

  @override
  State<TrailerVideoPlayerWeb> createState() => _TrailerVideoPlayerWebState();
}

class _TrailerVideoPlayerWebState extends State<TrailerVideoPlayerWeb> {
  late VideoJsController _videoJsController;

  @override
  void initState() {
    super.initState();
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
          Source(widget.baseItem.trailerUrl, "application/x-mpegURL"),
        ],
        suppressNotSupportedError: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: VideoJsWidget(
          videoJsController: _videoJsController,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}
