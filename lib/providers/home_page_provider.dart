import 'package:flutter/cupertino.dart';

  class HomePageProvider extends ChangeNotifier {
  int currentIndex = 0;
  String? firstReelId;

  void redirectToReels(String? param) {
    firstReelId = param;
    currentIndex = 3;
    notifyListeners();
  }
}