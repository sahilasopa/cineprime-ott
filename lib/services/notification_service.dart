import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/presentation/components/bottom_sheet/media_bottomsheet.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/services/network_service.dart';

import '../models/user/user.dart';

/// Payload from FCM data when user taps a notification (baseitem, redirect_type, etc.).
Map<String, String>? _pendingNotificationPayload;

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// FCM topic for "all users" broadcast; backend sends to this topic (no reliance on stored tokens).
  static const String topicAllUsers = 'all_users';

  /// Call after Firebase.init from main. Sets up getInitialMessage and onMessageOpenedApp.
  Future<void> initNotificationTapHandling() async {
    if (kIsWeb) return;
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleRemoteMessage(initialMessage);
      }
      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);
    } on Exception catch (e) {
      debugPrint('NotificationService.initNotificationTapHandling: $e');
    }
  }

  static void _handleRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) return;
    final baseitem = data['baseitem']?.toString().trim();
    final redirectType = (data['redirect_type'] ?? '').toString().trim().toLowerCase();
    final redirectUrl = data['redirect_url']?.toString().trim();
    final campaignId = data['campaign_id']?.toString().trim();
    if (baseitem == null && redirectUrl == null) return;
    _pendingNotificationPayload = {
      if (baseitem != null && baseitem.isNotEmpty) 'baseitem': baseitem,
      if (redirectType.isNotEmpty) 'redirect_type': redirectType,
      if (redirectUrl != null && redirectUrl.isNotEmpty) 'redirect_url': redirectUrl,
      if (campaignId != null && campaignId.isNotEmpty) 'campaign_id': campaignId,
    };
    if (campaignId != null && campaignId.isNotEmpty) {
      // Fire-and-forget; app may not be fully ready to await.
      _instance._reportCampaignEvent(campaignId, 'open');
    }
  }

  /// Returns and keeps the pending payload until [clearPending] or [tryConsume] is called.
  Map<String, String>? getPendingPayload() => _pendingNotificationPayload;

  /// Consume pending notification: resolve content, navigate or open URL, report click, clear pending.
  /// Call from a widget that has [BuildContext] under [MultiProvider] and inside [MaterialApp] (e.g. MaterialApp builder).
  Future<void> tryConsume(BuildContext context) async {
    final payload = _pendingNotificationPayload;
    if (payload == null || payload.isEmpty) return;
    final redirectType = payload['redirect_type'] ?? '';
    final redirectUrl = payload['redirect_url'];
    final baseitemId = payload['baseitem'];
    final campaignId = payload['campaign_id'];

    if (redirectType == 'external' && redirectUrl != null && redirectUrl.isNotEmpty) {
      _openUrl(redirectUrl);
      if (campaignId != null && campaignId.isNotEmpty) {
        await _reportCampaignEvent(campaignId, 'click');
      }
      _pendingNotificationPayload = null;
      return;
    }

    if (redirectType != 'baseitem' || baseitemId == null || baseitemId.isEmpty) {
      _pendingNotificationPayload = null;
      return;
    }

    try {
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      final baseItem = contentProvider.getMediaById(baseitemId);
      if (baseItem != null) {
        showBottomSheetOrNavigate(context, baseItem);
        if (campaignId != null && campaignId.isNotEmpty) {
          await _reportCampaignEvent(campaignId, 'click');
        }
      }
    } catch (_) {}
    _pendingNotificationPayload = null;
  }

  void clearPending() {
    _pendingNotificationPayload = null;
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('NotificationService._openUrl: $e');
    }
  }

  /// Gets current FCM token and, if user is logged in and token differs from [user].fcmToken, POSTs it to the backend.
  /// Call on permission grant, on token refresh, and when app starts with permission already granted.
  Future<void> reportFcmTokenToBackend(User? user) async {
    if (user == null) return;
    try {
      final String? fcmToken = await _messaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      if (user.fcmToken == fcmToken) return;
      NetworkService().post(
        APIPath.updateFCMToken,
        {"fcm_token": fcmToken},
        (_) {},
        (_) {},
        () {},
      );
    } on Exception {
      // pass
    }
  }

  /// Subscribes to FCM token refresh and reports the new token to the backend when [getCurrentUser] returns a user.
  /// Call once from a widget that has access to auth (e.g. MainApp.initState with Provider).
  void startTokenRefreshListener(Future<User?> Function() getCurrentUser) {
    _messaging.onTokenRefresh.listen((_) async {
      final user = await getCurrentUser();
      await reportFcmTokenToBackend(user);
    });
  }

  /// Reports open/click to the backend. Returns a Future so callers can await to ensure the request completes.
  Future<void> _reportCampaignEvent(String campaignId, String event) async {
    if (event != 'open' && event != 'click') return;
    await NetworkService().post(
      APIPath.notificationCampaignEvent,
      {'campaign_id': campaignId, 'event': event},
      (_) {},
      (_) {},
      () {},
    );
  }

  Future<void> requestNotificationPermission(User? user) async {
    try {
      final String? fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await reportFcmTokenToBackend(user);
        await _messaging.subscribeToTopic(topicAllUsers);
      }
      final NotificationSettings notificationSettings =
          await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: false,
      );
      _handleAuthorizationStatus(notificationSettings.authorizationStatus);
    } on Exception {
      // pass
    }
  }

  void _handleAuthorizationStatus(AuthorizationStatus authorizationStatus) {
    switch (authorizationStatus) {
      case AuthorizationStatus.authorized:
        break;
      case AuthorizationStatus.provisional:
        break;
      default:
        break;
    }
  }

  Future<bool> isNotificationPermissionGranted() async {
    try {
      final NotificationSettings settings =
          await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } on Exception {
      return false;
    }
  }
}
