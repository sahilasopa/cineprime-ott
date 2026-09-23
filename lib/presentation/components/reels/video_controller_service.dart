import 'dart:async';
import 'dart:developer'; // For logging
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

// Abstract class defining a service for obtaining video controllers
abstract class CustomVideoControllerService {
  // Method to get a VideoPlayerController for a given video URL
  Future<VideoPlayerController> getControllerForVideo(
      String url, bool isCaching);
}

// Implementation of CustomVideoControllerService that uses caching
class CachedCustomVideoControllerService extends CustomVideoControllerService {
  final BaseCacheManager _cacheManager; // Cache manager instance

  CachedCustomVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getControllerForVideo(
      String url, bool isCaching) async {
    if (isCaching) {
      FileInfo?
          fileInfo; // Variable to store file info if video is found in cache

      try {
        // Attempt to retrieve video file from cache
        fileInfo = await _cacheManager.getFileFromCache(url);
      } catch (e) {
        // Log error if encountered while getting video from cache
        log('Error getting video from cache: $e');
      }

      // Check if video file was found in cache
      if (fileInfo != null) {
        return VideoPlayerController.file(fileInfo.file);
      }

      try {
        _cacheManager.downloadFile(url);
      } catch (e) {
        // Log error if encountered while downloading video
        log('Error downloading video: $e');
      }
    }

    // Return VideoPlayerController for the video from the network
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }
}
