import 'package:flutter/widgets.dart';

class VideoJsController {
  final String id;
  final VideoJsOptions? videoJsOptions;

  VideoJsController(this.id, {this.videoJsOptions});
}

class VideoJsOptions {
  final bool controls;
  final bool loop;
  final bool muted;
  final String? poster;
  final String? aspectRatio;
  final bool fluid;
  final String? language;
  final bool liveui;
  final String? notSupportedMessage;
  final List<double>? playbackRates;
  final bool responsive;
  final List<Source>? sources;
  final bool suppressNotSupportedError;

  const VideoJsOptions({
    this.controls = false,
    this.loop = false,
    this.muted = false,
    this.poster,
    this.aspectRatio,
    this.fluid = false,
    this.language,
    this.liveui = false,
    this.notSupportedMessage,
    this.playbackRates,
    this.responsive = false,
    this.sources,
    this.suppressNotSupportedError = false,
  });
}

// video_js_stub.dart
class VideoJsResults {
  void init() {
    // No operation on non-web platforms
  }
}


class Source {
  final String src;
  final String type;

  const Source(this.src, this.type);
}

class VideoJsWidget extends StatelessWidget {
  final VideoJsController videoJsController;
  final double? width;
  final double? height;

  const VideoJsWidget({
    super.key,
    required this.videoJsController,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
