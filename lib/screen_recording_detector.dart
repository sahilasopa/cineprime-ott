import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenRecordingBlocker extends StatefulWidget {
  const ScreenRecordingBlocker({Key? key}) : super(key: key);

  @override
  _ScreenRecordingBlockerState createState() => _ScreenRecordingBlockerState();
}

class _ScreenRecordingBlockerState extends State<ScreenRecordingBlocker> {
  static const EventChannel _screenRecordingChannel =
  EventChannel('screen_recording');
  bool _isScreenRecording = false;

  @override
  void initState() {
    super.initState();
    _screenRecordingChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is bool) {
        setState(() {
          _isScreenRecording = event;
        });
      }
    }, onError: (error) {
      print("Error receiving screen recording events: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isScreenRecording) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'Screen recording is blocked',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
