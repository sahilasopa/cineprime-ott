import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _notificationPermissionGrantedKey = 'notification_permission_granted';

  static Future<bool> isNotificationPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationPermissionGrantedKey) ?? false;
  }

  static Future<void> setNotificationPermissionGranted(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPermissionGrantedKey, granted);
  }
}
