import 'package:background_downloader/background_downloader.dart';

import 'download_item.dart';

class DownloadItemWrapper {
  final TaskStatusUpdate? update;
  final DownloadedBaseItem downloadedBaseItem;

  DownloadItemWrapper(this.update, this.downloadedBaseItem);
}
