import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deeplinkly/flutter_deeplinkly.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/deeplink_pending_handler.dart';
import 'package:cineprime/deep_links_handler.dart';
import 'package:cineprime/presentation/main.dart';
import 'package:cineprime/presentation/pages/authentication/force_update_page.dart';
import 'package:cineprime/presentation/pages/authentication/login_screen.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/providers/download_provider.dart';
import 'package:cineprime/providers/home_page_provider.dart';
import 'package:cineprime/providers/in_app_notification_provider.dart';
import 'package:cineprime/providers/my_list_provider.dart';
import 'package:cineprime/providers/reels_provider.dart';
import 'package:cineprime/services/download_service.dart';
import 'package:cineprime/services/hive_service.dart';
import 'package:cineprime/services/notification_service.dart';
import 'package:provider/provider.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import 'firebase_options.dart';
import 'models/media/download_item.dart';
import 'package:cineprime/video_js_bridge.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    WakelockPlus.enable();
  } else {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "FACEBOOK_APP_ID",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    if (!kIsWeb) {
      await NotificationService().initNotificationTapHandling();
    }
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  await Hive.initFlutter();
  Hive.registerAdapter(DownloadedBaseItemAdapter());

  if (!kIsWeb) {
    FileDownloader().configure(
      androidConfig: [
        (Config.runInForeground, true),
        (Config.checkAvailableSpace, 10),
      ],
    );
  }

  FlutterDeeplinkly.init();
  // Register early so we receive cold-start link params (app launched from link)
  FlutterDeeplinkly.onResolved((params) {
    DeeplinkPendingHandler.instance.setPending(Map<String, dynamic>.from(params));
  });

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF07070C),
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  if (!kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      final errorString = errorDetails.exception.toString();
      if (errorString.contains('Software caused connection abort') ||
          errorString.contains('Video player had error') ||
          errorString.contains('Connection closed while receiving') ||
          errorString.contains('HandshakeException') ||
          errorString.contains('ClientException: Connection closed before full') ||
          errorString.contains('ClientException with SocketException:') ||
          errorString.contains('PathNotFoundException') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('MediaCodecVideoRenderer error')) {
        return;
      }
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      final errorString = error.toString();
      if (errorString.contains('Software caused connection abort') ||
          errorString.contains('Video player had error') ||
          errorString.contains('Connection closed while receiving') ||
          errorString.contains('HandshakeException') ||
          errorString.contains('ClientException: Connection closed before full') ||
          errorString.contains('ClientException with SocketException:') ||
          errorString.contains('PathNotFoundException') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('MediaCodecVideoRenderer error')) {
        return true;
      }
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Enforce portrait mode.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Providers and any background services.
  final List providers = [];
  final authenticationProvider = AuthenticationProvider();
  final inAppNotificationsProvider = InAppNotificationProvider();
  if (!kIsWeb) {
    final downloadProvider = DownloadProvider.instance;
    await downloadProvider.init();
    DownloadService().emitDownloadListeners();
    downloadProvider.listenToDownloadStream();
    await FileDownloader().resumeFromBackground();
    providers.add(ChangeNotifierProvider(create: (_) => downloadProvider));
    FileDownloader().trackTasks();
  }
  final contentProvider = ContentProvider();
  final homePageProvider = HomePageProvider();
  final reelsProvider = ReelsProvider();
  final myListProvider = MyListProvider();
  await myListProvider.init();
  if (!kIsWeb) {
    reelsProvider.loadReels();
  }
  Map<String, dynamic> config = {};
  try {
    config = await contentProvider.getConfig().timeout(const Duration(seconds: 20));
  } catch (e) {
    // Don't block startup on the splash screen if config fails to load.
    debugPrint("Config load error: $e");
  }
  final loginMethod = (config['login_method'] ?? 'A').toString().toUpperCase();

  // Version check: compare app version code (int) with server minimum.
  // Use build number as the comparable integer (e.g. 31 for 3.1.0+31).
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
  if (contentProvider.isUpdateRequired(currentVersionCode)) {
    final releaseNotes = contentProvider.releaseNotes;
    runApp(MaterialApp(
      theme: AppTheme.dark(),
      home: ForceUpdatePage(
        releaseNotes: releaseNotes.isEmpty ? null : releaseNotes,
      ),
    ));
    return;
  }

  Widget? nextPage;

  Future<void> safeInit() async {
    final completer = Completer<void>();

    await authenticationProvider.init(
      (user) {
        final hasPlan = user.userSubscription != null;
        if (loginMethod == 'C' && !hasPlan) nextPage = PlansListPage();
        completer.complete();
      },
      (_) {
        nextPage = LoginPage();
        completer.complete();
      },
    );

    await completer.future;

    // Hardened fallback (in case init didn't trigger callbacks correctly)
    if (authenticationProvider.getUser() == null) {
      nextPage ??= LoginPage();
    } else if (loginMethod == 'C' && authenticationProvider.getUser()?.userSubscription == null) {
      nextPage ??= PlansListPage();
    }
  }

  if (loginMethod == 'A') {
    await authenticationProvider.init((_) {}, (_) {});
  } else {
    await safeInit();
  }

  HiveService.instance.init();
  await contentProvider.init(
    onComplete: () {
      inAppNotificationsProvider.init();
      DeeplinkPendingHandler.instance.onContentReady();
    },
  );
  VideoJsResults().init();

  // Finally, run the app.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authenticationProvider),
        ChangeNotifierProvider(create: (_) => inAppNotificationsProvider),
        ChangeNotifierProvider(create: (_) => contentProvider),
        ChangeNotifierProvider(create: (_) => reelsProvider),
        ChangeNotifierProvider(create: (_) => homePageProvider),
        ChangeNotifierProvider(create: (_) => myListProvider),
        ...providers,
      ],
      child: DeepLinkHandler(child: MainApp(nextPage: nextPage)),
    ),
  );
}
