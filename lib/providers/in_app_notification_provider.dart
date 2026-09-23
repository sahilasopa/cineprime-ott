import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cineprime/models/notification.dart';
import 'package:cineprime/models/user/user.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/services/authentication_service.dart';
import 'package:cineprime/services/media_service.dart';
import 'package:cineprime/services/network_service.dart';

typedef OnSuccessCallback = void Function(User user);
typedef OnFailureCallback = void Function(dynamic error);

class InAppNotificationProvider extends ChangeNotifier {
  AuthenticationService authenticationService = AuthenticationService();
  List<NotificationModel> _notifications = [];

  Future<void> init() async {
    await NetworkService().get(APIPath.inAppNotifications, (data) {
      final mediaService = MediaService.instance;

      final items = (data['body']['data'] as List)
          .map((item) => NotificationModel.fromMap(item))
          .toList();
      for (var item in items) {
        if (item.type == NotificationType.newRelease) {
          item.baseItem = mediaService.getMediaById(item.baseItemId!, null);
        }
      }
      _notifications = items;
      notifyListeners();
    }, (error) {
      // Handle error if needed
    }, () {}, maxRetries: 100);
  }

  List<NotificationModel> getNotifications() {
    return _notifications;
  }
}
