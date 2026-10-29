import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:background_downloader/background_downloader.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cineprime/models/media/download_item.dart';
import 'package:cineprime/models/media/download_item_wrapper.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/models/user/user.dart';
import 'package:cineprime/services/download_service.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/services/media_service.dart';

enum DownloadStatus { downloading, downloaded, failed, paused, notDownloaded }

class DownloadProvider extends ChangeNotifier {
  DownloadProvider._();

  static final DownloadProvider _instance = DownloadProvider._();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _showChildSafe = false;

  Future<void> _loadToggleState() async {
    String? value = await storage.read(key: 'show_child_safe');
    _showChildSafe = value == 'true';
  }

  void applyChildSafe(bool value) {
    if (_showChildSafe == value) return;
    _showChildSafe = value;
    notifyListeners();
  }

  final Dio dio = Dio();
  final Map<String, DownloadItemWrapper> _downloads = {};
  final mediaService = MediaService.instance;
  final DownloadService downloadService = DownloadService();

  static DownloadProvider get instance => _instance;

  Future<void> init() async {
    _loadToggleState();
    _downloads.clear();
    final items = await downloadService.getDownloadedBaseItems();
    if (items != null) {
      for (int i = 0; i < items.length; i++) {
        _downloads[items.keys.elementAt(i)] = DownloadItemWrapper(
          null,
          items.values.elementAt(i),
        );
      }
    }
    notifyListeners();
  }

  Map<String, DownloadItemWrapper> getAllDownloads() {
    if (_showChildSafe) {
      return _downloads.entries
          .where((entry) => !entry.value.downloadedBaseItem.isAdult)
          .toList()
          .asMap()
          .map((_, entry) => MapEntry(entry.key, entry.value));
    }
    return _downloads;
  }

  Future<void> startDownload(BaseItem baseItem, User user) async {
    FirebaseAnalytics.instance
        .logEvent(name: "download_started", parameters: {"id": baseItem.id});
    if (!user.canDownload || user.userSubscription == null) return;
    print(baseItem.id);
    print(baseItem.downloadUrl);
    var metadataMap = {
      "id": baseItem.id,
      "plan_ends_at": user.userSubscription!.endTime.millisecondsSinceEpoch
    };
    final appDocDir = await getApplicationDocumentsDirectory();
    final box = await Hive.openBox<DownloadedBaseItem>('downloads');
    String posterSavePath = '${appDocDir.path}/${baseItem.id}.png';
    final task = DownloadTask(
      url: baseItem.downloadUrl,
      filename: 'video-${baseItem.id}.mp4',
      directory: "video",
      updates: Updates.statusAndProgress,
      allowPause: true,
      metaData: jsonEncode(metadataMap),
      retries: 6,
    );
    if (await FileDownloader().enqueue(task)) {
      await dio.download(
        baseItem.verticalPosterUrl.isNotEmpty ? baseItem.verticalPosterUrl : baseItem.horizontalPosterUrl,
        posterSavePath,
      );
    }
    final videoPath = await task.filePath();
    DownloadedBaseItem downloadedBaseItem = DownloadedBaseItem(
      id: baseItem.id,
      length: baseItem.length,
      title: baseItem.title,
      description: baseItem.description,
      posterPath: '${appDocDir.path}/${baseItem.id}.png',
      videoPath: videoPath,
      status: "downloading",
      taskId: task.taskId,
      isAdult: baseItem.getIsAdult(),
      validTill: min(
        DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        user.userSubscription?.endTime.millisecondsSinceEpoch ??
            999999999999999,
      ),
    );
    _downloads[downloadedBaseItem.id] =
        DownloadItemWrapper(null, downloadedBaseItem);
    await box.put(baseItem.id, downloadedBaseItem);
    notifyListeners();
  }

  void listenToDownloadStream() {
    downloadService.statusUpdate.listen((update) async {
      final box = await Hive.openBox<DownloadedBaseItem>('downloads');
      final downloadedBaseItem =
          _downloads[jsonDecode(update.task.metaData)['id']]
              ?.downloadedBaseItem;
      if (downloadedBaseItem != null) {
        switch (update.status) {
          case TaskStatus.enqueued:
            downloadedBaseItem.status = "waiting_to_start";
          case TaskStatus.running:
            downloadedBaseItem.status = "downloading";
          case TaskStatus.complete:
            downloadedBaseItem.status = "downloaded";
          case TaskStatus.notFound:
            downloadedBaseItem.status = "not_found";
          case TaskStatus.failed:
            downloadedBaseItem.status = "failed";
          case TaskStatus.canceled:
            deleteDownload(downloadedBaseItem.id, downloadedBaseItem.taskId);
            downloadedBaseItem.status = "canceled";
          case TaskStatus.waitingToRetry:
            downloadedBaseItem.status = "retrying";
          case TaskStatus.paused:
            downloadedBaseItem.status = "paused";
        }
        _downloads[jsonDecode(update.task.metaData)['id']] =
            DownloadItemWrapper(update, downloadedBaseItem);
        notifyListeners();
        await box.put(downloadedBaseItem.id, downloadedBaseItem);
      }
    });
    downloadService.progressUpdate.listen((event) {
      final downloadedBaseItem =
          _downloads[jsonDecode(event.task.metaData)['id']];
      if (downloadedBaseItem != null) {
        if (event.progress >= 0 && event.progress <= 1) {
          downloadedBaseItem.downloadedBaseItem.progress = event.progress;
          notifyListeners();
        }
      }
    });
  }

  DownloadItemWrapper? getDownloadedBaseItemWrapper(String baseItemId) {
    return _downloads[baseItemId];
  }

  Future<bool> pauseDownload(String taskId) async {
    return await downloadService.pauseDownload(taskId);
  }

  Future<bool> resumeDownload(String taskId) async {
    return await downloadService.resumeDownload(taskId);
  }

  void deleteDownload(String baseItemId, String? taskId) async {
    if (taskId != null) {
      FileDownloader().cancelTaskWithId(taskId);
    }
    _downloads.remove(baseItemId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    await downloadService.deleteDownload(baseItemId);
  }
}
