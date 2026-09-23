import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/models/media/reel_item.dart';
import 'package:cineprime/services/media_service.dart';

import '../network/api_paths.dart';
import '../services/network_service.dart';

enum Status { fetched, fetching, failed }

class ReelsProvider extends ChangeNotifier {
  final mediaService = MediaService.instance;

  List<ReelItem> getReels() {
    return mediaService.getReels();
  }

  void clearReels() {
    mediaService.clearReels();
  }

  Future<void> loadReels(
      {bool clear = false, dynamic firstId, VoidCallback? onSuccess}) async {
    await NetworkService().post(
      APIPath.getReels,
      {
        'ids_to_exclude': clear
            ? []
            : getReels()
                .map(
                  (mini) => mini.id,
                )
                .toList(),
        'first_id': firstId,
      },
      (data) {
        final List<dynamic> newData = data['body']['data'];
        if (newData.isNotEmpty) {
          if (clear) {
            mediaService.clearReels();
          }
          mediaService.addReels(
            newData
                .map(
                  (json) => ReelItem.fromJson(json),
                )
                .toList(),
          );
          if (onSuccess != null) {
            onSuccess();
          }
          notifyListeners();
        }
      },
      (error) {},
      () {},
    );
  }
}
