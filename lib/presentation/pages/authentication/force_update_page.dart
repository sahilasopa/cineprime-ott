import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown when server requires a newer app version (compare by integer version code).
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key, this.releaseNotes});

  final String? releaseNotes;

  static Future<void> openStore() async {
    final uri = PlatformUtils.isAndroid
        ? Uri.parse('https://play.google.com/store/apps/details?id=app.cineprimeott.app')
        : PlatformUtils.isIOS
            ? Uri.parse('https://apps.apple.com/app/id') // Replace with real App Store ID
            : null;
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReleaseNotes = releaseNotes != null && releaseNotes!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: AppBackground(
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.system_update_alt,
                    size: 80,
                    color: AppColors.colorPrimary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Update required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A new version of the app is available. Please update to continue.',
                    style: TextStyle(
                      color: AppColors.colorHint,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasReleaseNotes) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.colorPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's new",
                            style: TextStyle(
                              color: AppColors.colorPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            releaseNotes!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!PlatformUtils.isWeb) ...[
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Update',
                      onPressed: () => openStore(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
