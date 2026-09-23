import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/models/media/reel_item.dart';
import 'package:cineprime/models/media/section.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/services/media_service.dart';
import 'package:cineprime/services/network_service.dart';

enum Status { fetched, fetching, failed }

class ContentProvider extends ChangeNotifier {
  final mediaService = MediaService.instance;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool _showChildSafe = false;
  bool _isToggling = false;
  Future<Map<String, dynamic>>? _loadingFuture;
  Map<String, dynamic> _config = {};

  bool get showChildSafe => _showChildSafe;

  Future<void> init({VoidCallback? onComplete}) async {
    await _loadToggleState();
    mediaService.init(() {
      notifyListeners();
      onComplete?.call();
    }, isChildSafe: _showChildSafe);
    // Rebuild immediately so UI can show shimmer while content is loading
    notifyListeners();
  }

  String getLoginConfigConfirm() {
    final c = _config['login_method'] ?? 'A';
    return c.toString().toUpperCase();
  }

  Map<String, dynamic> getConfigConfirm() {
    return _config;
  }

  /// Minimum required app version code (integer from API). Null means no enforcement.
  int? get minimumVersionCode {
    final v = _config['minimum_version'];
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final parsed = int.tryParse(v.toString().trim());
    return parsed;
  }

  /// True if the app must be updated (current version code < required).
  bool isUpdateRequired(int currentVersionCode) {
    final minimum = minimumVersionCode;
    if (minimum == null) return false;
    return currentVersionCode < minimum;
  }

  Future<Map<String, dynamic>> getConfig() {
    if (_loadingFuture != null) return _loadingFuture!;

    final completer = Completer<Map<String, dynamic>>();
    _loadingFuture = completer.future;

    NetworkService().get(
      APIPath.getConfig,
      (data) {
        final body = data['body'] as Map<String, dynamic>? ?? {};
        _config = body;
        completer.complete(body);
        _loadingFuture = null;
      },
      (error) {
        completer.completeError(error);
        _loadingFuture = null;
      },
      () {},
    );

    return completer.future;
  }

  // Get policy content directly from config
  Future<String?> getPrivacyPolicy() async {
    return _config['privacy_policy']?.toString();
  }

  Future<String?> getTermsOfUse() async {
    return _config['terms_of_use']?.toString();
  }

  Future<String?> getRefundPolicy() async {
    return _config['refund_policy']?.toString();
  }

  Future<String?> getAboutUs() async {
    return _config['about_us']?.toString();
  }

  /// Release notes from config (What's new). Empty string if not set.
  String get releaseNotes => _config['release_notes']?.toString().trim() ?? '';

  Future<void> _loadToggleState() async {
    String? value = await storage.read(key: 'show_child_safe');
    _showChildSafe = value == 'true';
  }

  String getReferralText(String code) {
    return mediaService.getReferralText(code);
  }

  String? getReferralVideoUrl() {
    return mediaService.getReferralVideoUrl();
  }

  String? getReferralPosterUrl() {
    return mediaService.getReferralPosterUrl();
  }

  Future<void> toggleSwitch() async {
    if (_isToggling) return; // Prevent concurrent toggles
    _isToggling = true;
    try {
      _showChildSafe = !showChildSafe;
      await storage.write(
          key: 'show_child_safe', value: _showChildSafe.toString());
      mediaService.init(() {
        notifyListeners();
      }, isChildSafe: _showChildSafe);
    } finally {
      _isToggling = false;
    }
  }

  String getSupportPhoneNumber() {
    return mediaService.getSupportPhoneNumber();
  }

  String getShareText() {
    return mediaService.getShareText();
  }

  String getShareUrl() {
    return mediaService.getShareUrl();
  }

  String getAlertTitle() {
    return mediaService.getAlertTitle();
  }

  String getAlertMessage() {
    return mediaService.getAlertMessage();
  }

  void getVideoUrls(
      String baseItemId, MediaType mediaType, void Function() onSuccess,
      {String parentId = ""}) {
    mediaService.getVideoUrls(
      baseItemId,
      mediaType,
      () {
        onSuccess();
      },
      _showChildSafe,
      parentId: parentId,
    );
  }

  String getSupportEmail() {
    return mediaService.getSupportEmail();
  }

  String getSupportTiming() {
    return mediaService.getSupportTiming();
  }

  String getGrievanceName() {
    return mediaService.getGrievanceName();
  }

  String getGrievanceEmail() {
    return mediaService.getGrievanceEmail();
  }

  List<Section> getSections() {
    return mediaService.getSections().map((section) {
      return section.copyWith(
        baseItems: _showChildSafe
            ? section.baseItems.where((item) => !item.getIsAdult()).toList()
            : section.baseItems,
      );
    }).toList();
  }

  List<BaseItem> getUpcoming() {
    if (showChildSafe) {
      return mediaService
          .getUpcoming()
          .where((element) => !element.getIsAdult())
          .toList();
    }
    return mediaService.getUpcoming();
  }

  List<ReelItem> getReels() {
    return mediaService.getReels();
  }

  Status? getStatus() {
    return mediaService.getStatus();
  }

  List<BaseItem> getMovies() {
    if (showChildSafe) {
      return mediaService
          .getMovies()
          .where((element) => !element.getIsAdult())
          .toList();
    }
    return mediaService.getMovies();
  }

  List<BaseItem> getPosters() {
    if (showChildSafe) {
      return mediaService
          .getPosters()
          .where((element) => !element.getIsAdult())
          .toList();
    }
    return mediaService.getPosters();
  }

  List<BaseItem> getSuggestionMovies(List<String> suggestions) {
    return getMovies().where((item) => suggestions.contains(item.id)).toList();
  }

  List<BaseItem> getSeries() {
    return mediaService.getSeries(childSafe: _showChildSafe);
  }

  BaseItem? getMediaById(String id, [MediaType? mediaType]) {
    return mediaService.getMediaById(id, mediaType);
  }

  void updateWatchTimestamp(String itemId, int timestampInSeconds) {
    final mediaService = this.mediaService;
    BaseItem? targetItem;

    void updateInList(List<BaseItem> list) {
      for (var item in list) {
        if (item.id == itemId) {
          item.lastTimestamp = timestampInSeconds;
          targetItem ??= item;
          break;
        }
      }
    }

    updateInList(mediaService.getMovies());
    updateInList(mediaService.getPosters());
    updateInList(mediaService.getUpcoming());
    updateInList(mediaService.getSeries());

    for (var series in mediaService.getSeries()) {
      updateInList(series.episodes);
    }

    for (var section in mediaService.getSections()) {
      updateInList(section.baseItems);
    }

    if (targetItem != null) {
      final continueSection = mediaService.getSections().firstWhereOrNull(
            (section) => section.title == "Continue Watching",
          );

      if (continueSection != null) {
        final existingIndex =
            continueSection.baseItems.indexWhere((i) => i.id == targetItem!.id);
        if (existingIndex != -1) {
          continueSection.baseItems.removeAt(existingIndex);
        }
        continueSection.baseItems.insert(0, targetItem!);
      } else {
        final newSection = Section(
          title: "Continue Watching",
          type: "horizontal",
          priority: 1,
          itemIds: [targetItem!.id],
          baseItems: [targetItem!],
          isContinueWatching: true,
        );
        mediaService.getSections().insert(1, newSection);
      }
    }

    notifyListeners();
  }

  void removeContinueWatching() {
    final sections = mediaService.getSections();

    // Remove "Continue Watching" section
    final continueSection = sections.firstWhereOrNull(
      (section) => section.title == "Continue Watching",
    );
    if (continueSection != null) {
      sections.remove(continueSection);
    }

    // Helper to clear timestamp in a list
    void clearInList(List<BaseItem> list) {
      for (final item in list) {
        item.lastTimestamp = null;
      }
    }

    // Clear from all sources
    clearInList(mediaService.getMovies());
    clearInList(mediaService.getPosters());
    clearInList(mediaService.getUpcoming());
    clearInList(mediaService.getSeries());
    for (var series in mediaService.getSeries()) {
      clearInList(series.episodes);
    }
    for (var section in mediaService.getSections()) {
      clearInList(section.baseItems);
    }

    notifyListeners();
  }

  void removeFromContinueWatching(BaseItem baseItem) {
    final sections = mediaService.getSections();

    // Find the Continue Watching section
    final continueSection = sections.firstWhereOrNull(
      (section) => section.title == "Continue Watching",
    );

    if (continueSection == null) return;

    // Remove matching item
    continueSection.baseItems.removeWhere((item) => item.id == baseItem.id);

    // If empty, remove entire section
    if (continueSection.baseItems.isEmpty) {
      sections.remove(continueSection);
    }

    notifyListeners();
  }
}
