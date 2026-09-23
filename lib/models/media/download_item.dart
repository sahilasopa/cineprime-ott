import 'package:hive/hive.dart';

part 'download_item.g.dart';

@HiveType(typeId: 0)
class DownloadedBaseItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String posterPath;

  @HiveField(4)
  final String videoPath;

  @HiveField(5)
  final String length;

  @HiveField(6)
  String status;

  @HiveField(7)
  final String taskId;

  @HiveField(8)
  final bool isAdult;

  @HiveField(9)
  double progress = 0.0;

  @HiveField(10)
  int validTill = 0;

  DownloadedBaseItem({
    required this.id,
    required this.length,
    required this.title,
    required this.description,
    required this.posterPath,
    required this.videoPath,
    required this.taskId,
    required this.isAdult,
    required this.status,
    required this.validTill,
  });

  @override
  String toString() {
    return 'DownloadedBaseItem{id: $id, title: $title, description: $description, posterPath: $posterPath, videoPath: $videoPath, length: $length, status: $status, taskId: $taskId, isAdult: $isAdult, progress: $progress, validTill: $validTill}';
  }
}
