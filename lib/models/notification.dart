// models/notification_model.dart

import 'package:cineprime/models/media/media_item.dart';

enum NotificationType {
  info,
  subscription,
  newRelease,
  trailer,
}

class NotificationModel {
  final String title;
  final String image;
  final String? description;
  final String? time;
  final String? baseItemId;
  BaseItem? baseItem;
  final NotificationType type;

  NotificationModel({
    required this.title,
    String? image,
    this.description,
    this.time,
    this.baseItem,
    this.baseItemId,
    required this.type,
  }) : image = image ?? 'assets/images/cineprime-icon.png';

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'] as String,
      image: map['image'] as String?, // image might be null
      baseItemId: map['baseitem'] as String?, // image might be null
      description: map['message'] as String?, // adjust to 'message'
      time: map['time'] as String?, // optional field
      type: NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == map['notification_type'],
        orElse: () => NotificationType.info,
      ),
    );
  }


  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{
      'title': title,
      'image': image,
      'description': description,
      'type': type.toString().split('.').last,
    };
    if (time != null) {
      result['time'] = time;
    }
    return result;
  }
}
