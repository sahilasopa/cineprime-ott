import 'package:hive/hive.dart';

import '../models/media/download_item.dart';

class HiveService {
  HiveService._privateConstructor();

  static final HiveService _instance = HiveService._privateConstructor();
  late Box<DownloadedBaseItem> _downloadBox;
  final List<DownloadedBaseItem> _downloads = [];

  static HiveService get instance => _instance;

  Future<void> init() async {
    _downloadBox = await Hive.openBox<DownloadedBaseItem>('downloads');
    _downloads.addAll(_downloadBox.values);
  }

  List<DownloadedBaseItem> getAllDownloads() {
    return _downloads;
  }
}
