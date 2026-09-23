import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/services/notification_service.dart';
import 'package:cineprime/services/preferences_service.dart';
import 'package:provider/provider.dart';
import 'package:cineprime/providers/authentication_provider.dart';

class NotificationPermissionModal extends StatelessWidget {
  const NotificationPermissionModal({super.key});

  static Future<void> showIfNeeded(BuildContext? context) async {
    // Skip on web platform
    if (PlatformUtils.isWeb) {
      return;
    }

    // Validate context is provided and mounted
    if (context == null || !context.mounted) {
      return;
    }

    // Check if user is logged in
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = authProvider.getUser();
    if (user == null) {
      return;
    }

    // Check if notification permission is already granted
    final notificationService = NotificationService();
    final isGranted = await notificationService.isNotificationPermissionGranted();
    
    // Also check our stored preference (in case permission was granted previously)
    final storedGranted = await PreferencesService.isNotificationPermissionGranted();
    
    if (isGranted || storedGranted) {
      // Permission already granted; still sync FCM token to backend (e.g. after token refresh or reinstall)
      await NotificationService().reportFcmTokenToBackend(user);
      return;
    }

    // Validate context one more time before showing dialog
    if (!context.mounted) {
      return;
    }

    // Show the modal (will show on every app open until permission is granted)
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => const NotificationPermissionModal(),
    );
  }

  Future<void> _enable(BuildContext context) async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = authProvider.getUser();
    await NotificationService().requestNotificationPermission(user);
    final isGranted = await NotificationService().isNotificationPermissionGranted();
    await PreferencesService.setNotificationPermissionGranted(isGranted);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    const borderWidth = 1.5;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.colorSurface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.45), width: borderWidth),
        ),
        child: Padding(
          padding: const EdgeInsets.all(borderWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(radius - borderWidth)),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1C2A3A), Color(0xFF121820), Color(0xFF1A160C)],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(Icons.notifications_rounded, color: AppColors.colorOnGold, size: 30),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'CINEPRIME',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.colorPrimaryLight,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Never miss a premiere',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                child: Column(
                  children: [
                    const Text(
                      'Allow notifications for new releases, exclusive titles, and offers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.colorTextSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: () => _enable(context),
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Allow',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.colorOnGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Not now',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppColors.colorPrimaryLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
