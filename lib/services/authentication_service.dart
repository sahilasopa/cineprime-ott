import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cineprime/models/user/user.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:cineprime/web_stub.dart' if (dart.library.html) 'package:web/web.dart' as web;

class AuthenticationService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _uidKey = 'session_id';
  String? _sessionId;
  User? user;
  late String country;
  bool _countryInitialized = false;
  bool _countryInitializing = false;

  Future<String> getCountry() async {
    if (_countryInitialized) return country;
    if (_countryInitializing) return "IN";
    // Set the guard synchronously so the geo-IP request below (which itself
    // goes through NetworkService and asks for X-Country) short-circuits to
    // "IN" instead of recursing.
    _countryInitializing = true;

    final completer = Completer<String>();
    // Fire-and-forget: do NOT await. Other requests use "IN" until this
    // resolves; once it succeeds the real country is cached for the session.
    // maxRetries: 1 so a down/slow host doesn't trigger the long retry loop.
    NetworkService().get(
      APIPath.getCountry,
      (data) {
        country = (data['body']?['country'] as String?) ?? "IN";
        _countryInitialized = true;
        if (!completer.isCompleted) completer.complete(country);
      },
      (error) {
        if (!completer.isCompleted) completer.complete("IN");
      },
      () {},
      maxRetries: 1,
    );

    // Never block a real request more than 3s on the geo lookup; fall back to
    // "IN" on timeout. The fetch keeps running in the background and populates
    // the cache for subsequent requests if it later succeeds.
    return completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => "IN",
    );
  }

  static final AuthenticationService _instance = AuthenticationService._internal();

  factory AuthenticationService() => _instance;

  AuthenticationService._internal();

  Future<void> setUser(User u) async {
    user = u;
    if (user != null) {
      await FirebaseCrashlytics.instance.setUserIdentifier(user!.id);
    }
  }

  Future<void> logout() async {
    bool hasKey = false;
    await FirebaseCrashlytics.instance.setUserIdentifier('anonymous');
    if (PlatformUtils.isWeb) {
      hasKey = web.window.localStorage.getItem(_uidKey) != null;
    } else {
      hasKey = await _secureStorage.containsKey(key: _uidKey);
    }
    if (hasKey) {
      NetworkService().post(
        APIPath.logout,
        {},
        (data) async {
          if (PlatformUtils.isWeb) {
            try {
              web.window.localStorage.removeItem(_uidKey);
            } catch (e) {
              print("Failed to remove sessionId from web: $e");
            }
          } else {
            try {
              await _secureStorage.delete(key: _uidKey); // <-- Await here
            } catch (e) {
              print("Failed to remove sessionId from storage: $e");
            }
          }
          _sessionId = null;
        },
        (error) {
          print("Logout failed: $error");
        },
        () {},
      );
    }
  }

  Future<void> saveSessionId(String? sessionId) async {
    _sessionId = sessionId;
    if (PlatformUtils.isWeb) {
      web.window.localStorage.setItem(_uidKey, sessionId ?? "anonymous_user");
    } else {
      await _secureStorage.write(key: _uidKey, value: sessionId);
    }
  }

  Future<String?> getSessionId() async {
    if (_sessionId != null) {
      return _sessionId;
    }
    if (PlatformUtils.isWeb) {
      return web.window.localStorage.getItem(_uidKey) ?? "anonymous_user";
    } else {
      return (await _secureStorage.read(key: _uidKey)) ?? "anonymous_user";
    }
  }
}
