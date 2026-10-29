import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:provider/provider.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _notifications = true;
  bool _wifiOnly = true;
  String _downloadQuality = 'High';

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final isLoggedIn = authenticationProvider.getUser() != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text('Playback', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          _SettingsSwitchRow(
            label: 'Notifications From Us',
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          const SizedBox(height: 24),
          const Text('Downloads', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          _SettingsSwitchRow(
            label: 'Download Only On Wifi',
            value: _wifiOnly,
            onChanged: (value) => setState(() => _wifiOnly = value),
          ),
          const SizedBox(height: 10),
          SurfaceCard(
            onTap: _showQualitySheet,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Default Download Quality',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(_downloadQuality, style: AppTextStyles.meta),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.colorTextMuted),
              ],
            ),
          ),
          if (isLoggedIn) ...[
            const SizedBox(height: 32),
            SurfaceCard(
              borderColor: Colors.redAccent.withValues(alpha: 0.45),
              onTap: () => _confirmDelete(authenticationProvider),
              child: const Row(
                children: [
                  Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Permanently Delete My Account',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showQualitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Download Quality', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              for (final quality in const ['Low', 'Medium', 'High'])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(quality, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: _downloadQuality == quality
                      ? const Icon(Icons.check_rounded, color: AppColors.colorPrimary)
                      : null,
                  onTap: () {
                    setState(() => _downloadQuality = quality);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(AuthenticationProvider authenticationProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Your Account?',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to permanently delete your account? This action cannot be undone, and any active subscription is non-refundable.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.colorTextSecondary, fontSize: 14, height: 1.45),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        NetworkService().post(
                          APIPath.deleteAccount,
                          {},
                          (data) {
                            Navigator.of(context).pop();
                            authenticationProvider.logout();
                          },
                          (error) {},
                          () {},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.colorPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
