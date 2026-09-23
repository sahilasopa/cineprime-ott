import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:cineprime/models/media/reel_item.dart';
import 'package:video_player/video_player.dart';
import 'video_controller_service.dart';

// Controller class for managing the reels in the app
class CustomWhiteCodelReelsController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  // Page controller for managing pages of videos
  PageController pageController = PageController(viewportFraction: 0.99999);

  // List of video player controllers
  RxList<VideoPlayerController> videoPlayerControllerList =
      <VideoPlayerController>[].obs;

  // Service for managing cached video controllers
  CachedCustomVideoControllerService CustomVideoControllerService =
      CachedCustomVideoControllerService(DefaultCacheManager());

  // Observable for loading state
  final loading = true.obs;

  // Observable for visibility state
  final visible = false.obs;

  // Animation controller for animating
  bool isDisposed = true;
  late AnimationController animationController;

  // Animation object
  late Animation animation;

  // Current page index
  int page = 1;

  // Limit for loading videos
  int limit = 6;

  // List of video URLs
  final List<ReelItem> reelsVideoList;

  // isCaching
  bool isCaching;

  // Observable list of video URLs
  RxList<ReelItem> videoList = <ReelItem>[].obs;

  // Limit for loading nearby videos
  int loadLimit = 5;

  // Flag for initialization
  bool init = false;

  // Timer for periodic tasks
  Timer? timer;

  // Index of the last video
  int? lastIndex;

  // Already listened list
  List<int> alreadyListened = [];

  // Caching video at index
  List<String> caching = [];

  // pageCount
  RxInt pageCount = 0.obs;

  // Constructor
  CustomWhiteCodelReelsController(
      {required this.reelsVideoList, required this.isCaching});

  // Lifecycle method for handling app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Pause all video players when the app is paused
      for (var i = 0; i < videoPlayerControllerList.length; i++) {
        videoPlayerControllerList[i].pause();
      }
    }
  }

  // Lifecycle method called when the controller is initialized
  @override
  void onInit() {
    super.onInit();
    videoList.addAll(reelsVideoList);
    // Initialize animation controller
    isDisposed = false;
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    // Initialize service and start timer
    initService();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (lastIndex != null) {
        initNearByVideos(lastIndex!);
      }
    });
  }

  // Lifecycle method called when the controller is closed
  @override
  void onClose() {
    isDisposed = true;
    animationController.dispose();
    // Pause and dispose all video players
    for (var i = 0; i < videoPlayerControllerList.length; i++) {
      videoPlayerControllerList[i].pause();
      videoPlayerControllerList[i].dispose();
    }
    super.onClose();
  }

  initService() async {
    await addVideosController();
    int myindex = 0;
    if (!videoPlayerControllerList[myindex].value.isInitialized) {
      cacheVideo(myindex);
      await videoPlayerControllerList[myindex].initialize();
      increasePage(myindex + 1);
    }
    if (isDisposed) return;
    animationController.repeat();
    videoPlayerControllerList[myindex].play();
    refreshView();
    // listenEvents(myindex);
    await initNearByVideos(3);
    loading.value = false;
  }

  // Refresh loading state
  refreshView() {
    loading.value = true;
    loading.value = false;
  }

  // Add video controllers
  addVideosController() async {
    for (var i = 0; i < videoList.length; i++) {
      String videoFile = videoList[i].videoUrl;
      final controller =
          await CustomVideoControllerService.getControllerForVideo(
        videoFile,
        isCaching,
      );
      videoPlayerControllerList.add(controller);
    }
  }

  // Initialize nearby videos
  initNearByVideos(int index, {bool forcePlay = false}) async {
    if (init) {
      lastIndex = index;
      return;
    }
    lastIndex = null;
    init = true;
    if (loading.value) return;
    disposeNearByOldVideoControllers(index);
    await tryInit(index, forcePlay: forcePlay);
    try {
      var currentPage = index;
      var maxPage = currentPage + loadLimit;
      List<ReelItem> videoFiles = videoList;

      for (var i = currentPage; i < maxPage; i++) {
        if (videoFiles.asMap().containsKey(i)) {
          var controller = videoPlayerControllerList[i];
          if (!controller.value.isInitialized) {
            cacheVideo(i);
            await controller.initialize();
            increasePage(i + 1);
            refreshView();
            // listenEvents(i);
          }
        }
      }
      for (var i = index - 1; i > index - loadLimit; i--) {
        if (videoList.asMap().containsKey(i)) {
          var controller = videoPlayerControllerList[i];
          if (!controller.value.isInitialized) {
            cacheVideo(index);
            await controller.initialize();
            increasePage(i + 1);
            refreshView();
            // listenEvents(i);
          }
        }
      }

      refreshView();
      loading.value = false;
    } catch (e) {
      loading.value = false;
    } finally {
      loading.value = false;
    }
    init = false;
  }

  // Try initializing video at index
  tryInit(int index, {bool forcePlay = false}) async {
    var oldVideoPlayerController = videoPlayerControllerList[index];
    if (oldVideoPlayerController.value.isInitialized) {
      if (!forcePlay) {
        oldVideoPlayerController.pause();
      }
      refresh();
      return;
    }
    VideoPlayerController videoPlayerControllerTmp =
        await CustomVideoControllerService.getControllerForVideo(
            videoList[index].videoUrl, isCaching);
    videoPlayerControllerList[index] = videoPlayerControllerTmp;
    await oldVideoPlayerController.dispose();
    refreshView();
    cacheVideo(index);
    await videoPlayerControllerTmp
        .initialize()
        .catchError((e) {})
        .then((value) {
      videoPlayerControllerTmp.play();
      refresh();
    });
  }

  // Dispose nearby old video controllers
  disposeNearByOldVideoControllers(int index) async {
    loading.value = false;
    for (var i = index - loadLimit; i > 0; i--) {
      if (videoPlayerControllerList.asMap().containsKey(i)) {
        var oldVideoPlayerController = videoPlayerControllerList[i];
        VideoPlayerController videoPlayerControllerTmp =
            await CustomVideoControllerService.getControllerForVideo(
                videoList[i].videoUrl, isCaching);
        videoPlayerControllerList[i] = videoPlayerControllerTmp;
        alreadyListened.remove(i);
        await oldVideoPlayerController.dispose();
        refreshView();
      }
    }

    for (var i = index + loadLimit; i < videoPlayerControllerList.length; i++) {
      if (videoPlayerControllerList.asMap().containsKey(i)) {
        var oldVideoPlayerController = videoPlayerControllerList[i];
        VideoPlayerController videoPlayerControllerTmp =
            await CustomVideoControllerService.getControllerForVideo(
                videoList[i].videoUrl, isCaching);
        videoPlayerControllerList[i] = videoPlayerControllerTmp;
        alreadyListened.remove(i);
        await oldVideoPlayerController.dispose();
        refreshView();
      }
    }
  }

  // Listen to video events
  listenEvents(i, {bool force = false}) {
    if (alreadyListened.contains(i) && !force) return;
    alreadyListened.add(i);
    var videoPlayerController = videoPlayerControllerList[i];

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.position ==
              videoPlayerController.value.duration &&
          videoPlayerController.value.duration != Duration.zero) {
        videoPlayerController.seekTo(Duration.zero);
        videoPlayerController.play();
      }
    });
  }

  // Listen to page events
  // pageEventsListen(path) {
  //   pageController.addListener(() {
  //     visible.value = false;
  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       loading.value = false;
  //     });
  //     refreshView();
  //   });
  // }

  cacheVideo(int index) async {
    if (!isCaching) return;
    String url = videoList[index].videoUrl;
    if (caching.contains(url)) return;
    caching.add(url);
    final cacheManager = DefaultCacheManager();
    FileInfo? fileInfo = await cacheManager.getFileFromCache(url);
    if (fileInfo != null) {
      log('Video already cached: $index');
      return;
    }

    // log('Downloading video: $index');
    try {
      await cacheManager.downloadFile(url);
      // log('Downloaded video: $index');
    } catch (e) {
      // log('Error downloading video: $e');
      caching.remove(url);
    }
  }

  increasePage(v) {
    if (pageCount.value == videoList.length) return;
    if (pageCount.value >= v) return;
    pageCount.value = v;
  }
}
