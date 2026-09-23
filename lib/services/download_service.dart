import 'dart:async';
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cineprime/models/media/download_item.dart';
import 'package:cineprime/services/media_service.dart';

typedef ProgressCallback = void Function(double progress);
typedef SuccessCallback = void Function();
typedef FailureCallback = void Function(dynamic error);

class DownloadService {
  final mediaService = MediaService.instance;
  final StreamController<TaskProgressUpdate> _progressController = StreamController.broadcast();
  final StreamController<TaskStatusUpdate> _statusController = StreamController.broadcast();
  final _fileDownloader = FileDownloader();

  Stream<TaskProgressUpdate> get progressUpdate => _progressController.stream;

  Stream<TaskStatusUpdate> get statusUpdate => _statusController.stream;

  static final DownloadService _singleton = DownloadService._internal();
  final Dio dio = Dio();

  factory DownloadService() {
    return _singleton;
  }

  DownloadService._internal();

  void emitDownloadListeners() {
    _fileDownloader.updates.listen((update) async {
      switch (update) {
        case TaskStatusUpdate():
          _statusController.add(update);
        case TaskProgressUpdate():
          _progressController.add(update);
      }
    });
  }

  Future<Box<DownloadedBaseItem>?> getDownloadedBaseItems() async {
    try {
      return Hive.openBox<DownloadedBaseItem>('downloads');
    } catch (e) {
      return null;
    }
  }

  Future<bool> pauseDownload(String taskId) async {
    final task = await _fileDownloader.taskForId(taskId);
    if (task != null) {
      if (await _fileDownloader.taskCanResume(task)) {
        return await _fileDownloader.pause(task as DownloadTask);
      }
    }
    return false;
  }

  Future<bool> resumeDownload(String taskId) async {
    final task = await _fileDownloader.taskForId(taskId);
    if (task != null) {
      if (await _fileDownloader.taskCanResume(task)) {
        return await _fileDownloader.resume(task as DownloadTask);
      }
    }
    return false;
  }

  Future<void> deleteDownload(String id) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String videoSavePath = '${appDocDir.path}/video/video-$id.mp4';
    String posterSavePath = '${appDocDir.path}/$id.png';
    final videoFile = File(videoSavePath);
    final posterFile = File(posterSavePath);
    if (await videoFile.exists()) {
      await videoFile.delete();
    }
    if (await posterFile.exists()) {
      await posterFile.delete();
    }
    final box = await Hive.openBox<DownloadedBaseItem>('downloads');
    box.delete(id);
  }
}
