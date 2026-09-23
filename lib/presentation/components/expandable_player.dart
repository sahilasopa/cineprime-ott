import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';

class ExpandableWidget extends StatefulWidget {
  @override
  _ExpandableWidgetState createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> {
  bool isExpanded = false;

  void _openExpandedView(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) => ExpendedView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(animation);
        var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          _openExpandedView(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                color: Colors.grey,
                margin: const EdgeInsets.all(10),
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Never Gonna Give You Up",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Rick Astley",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Expanded(child: Container()),
              const Icon(
                Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
              const SizedBox(width: 22)
            ],
          ),
        ),
      ),
    );
  }
}

class ExpendedView extends StatefulWidget {
  @override
  State<ExpendedView> createState() => _ExpendedViewState();
}

class _ExpendedViewState extends State<ExpendedView> {
  bool isPlaying = false;

  // Play/Pause state
  double currentPosition = 0;

  // Current position of the seek bar
  double totalDuration = 100;

  // Example total duration for the seek bar
  bool isLooping = false;

  // Loop state
  double playbackSpeed = 1.0;

  // Playback speed
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.colorBackground,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.white,
        title: const Text("Music"),
        actions: const [
          Icon(Icons.more_vert, color: Colors.white,)
        ],
      ),
      backgroundColor: AppColors.colorBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Never Gonna Give You Up",
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          const Text(
            "Rick Astley",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Slider(
            value: currentPosition,
            min: 0,
            max: totalDuration,
            onChanged: (value) {
              setState(() {
                currentPosition = value;
              });
            },
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  isLooping ? Icons.loop : Icons.loop_outlined,
                  size: 28,
                ),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    isLooping = !isLooping;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
              ),
              PopupMenuButton<double>(
                icon: const Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 28,
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 0.5,
                      child: Text("0.5x"),
                    ),
                    PopupMenuItem(
                      value: 1.0,
                      child: Text("1.0x"),
                    ),
                    PopupMenuItem(
                      value: 1.5,
                      child: Text("1.5x"),
                    ),
                    PopupMenuItem(
                      value: 2.0,
                      child: Text("2.0x"),
                    ),
                  ];
                },
                onSelected: (value) {
                  setState(() {
                    playbackSpeed = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
