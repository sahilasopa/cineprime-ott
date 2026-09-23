import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/presentation/pages/home_page.dart';
import 'package:cineprime/presentation/purchase_history_page.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:cineprime/presentation/components/controls/text_input.dart';
import 'package:cineprime/presentation/components/logout_dialog.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:cineprime/presentation/pages/authentication/login_screen.dart';
import 'package:cineprime/presentation/pages/drawer_pages/contact_us_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/privacy_policy_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/terms_and_conditions_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/refund_policy_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/about_us_page.dart';
import 'package:cineprime/presentation/pages/fragments/my_list_page.dart';
import 'package:cineprime/presentation/pages/media/downloads_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/notifications_page.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/settings.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController deleteController = TextEditingController();
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    deleteController.dispose();
    super.dispose();
  }

  void _openManageProfiles(AuthenticationProvider auth) {
    final user = auth.getUser();
    usernameController.text = user?.username ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.colorSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manage Profile', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              TextInput(
                controller: usernameController,
                hintText: 'Full Name',
                obscureText: false,
                isLast: true,
                padding: 0,
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Save',
                onPressed: () async {
                  final username = usernameController.text.trim();
                  if (username.isEmpty) return;
                  await NetworkService().post(
                    APIPath.updateProfile,
                    {"username": username},
                    (data) {
                      auth.updateUsername(username);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Profile Updated Successfully')),
                      );
                    },
                    (error) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Profile Update Failed')),
                      );
                    },
                    () {},
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);
    final user = authenticationProvider.getUser();
    final isSubscribed = user?.userSubscription != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          child: Column(
            children: [
              Row(
                children: [
                  if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 40,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  CircleIconButton(
                    icon: Icons.settings_outlined,
                    size: 40,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AppSettingsPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 92,
                height: 92,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.45)),
                ),
                child: Image.asset('assets/images/cineprime-icon.png'),
              ),
              const SizedBox(height: 14),
              Text(
                user?.username?.isNotEmpty == true ? user!.username! : 'Guest',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                user?.getUniqueCredential().isNotEmpty == true
                    ? user!.getUniqueCredential()
                    : 'Sign in to personalize your experience',
                style: AppTextStyles.meta,
              ),
              const SizedBox(height: 14),
              if (user != null)
                GestureDetector(
                  onTap: () => _openManageProfiles(authenticationProvider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.colorSurfaceElevated,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'Manage Profiles',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else
                GradientButton(
                  label: 'Sign In',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlansListPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: AppColors.premiumGradient,
                    border: Border.all(color: AppColors.colorPrimary.withValues(alpha: 0.55)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.colorGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSubscribed ? (user?.userSubscription!.planName ?? 'Cineprime Premium') : 'Cineprime Premium',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSubscribed
                                  ? 'Valid until ${user?.userSubscription!.getDisplayEndTime()}'
                                  : 'Unlock a world of entertainment',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ProfileMenuTile(
                icon: Icons.bookmark_add_outlined,
                label: 'My List',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyListPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.download_outlined,
                label: 'Downloads',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DownloadsPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.history_rounded,
                label: 'Watch History',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyListPage()));
                },
              ),
              if (user != null)
                ProfileMenuTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Purchase History',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PurchaseHistoryPage()));
                  },
                ),
              ProfileMenuTile(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.child_care_outlined,
                label: 'Parental Controls',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.colorSurface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) {
                      return Consumer<ContentProvider>(
                        builder: (context, content, __) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Kids Mode',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Switch(
                                  value: content.showChildSafe,
                                  activeTrackColor: AppColors.colorPrimary,
                                  onChanged: (_) => content.toggleSwitch(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              ProfileMenuTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContactUsPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppSettingsPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PrivacyPolicyPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.article_outlined,
                label: 'Terms and Conditions',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => TermsAndConditionsPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.replay_circle_filled_outlined,
                label: 'Refund Policy',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => RefundPolicyPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.info_outline_rounded,
                label: 'About Us',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutUsPage()));
                },
              ),
              ProfileMenuTile(
                icon: Icons.star_border_rounded,
                label: 'Rate Us',
                onPressed: () => InAppReview.instance.openStoreListing(),
              ),
              if (user != null)
                ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  iconColor: AppColors.colorPrimary,
                  labelColor: AppColors.colorPrimary,
                  showChevron: false,
                  onPressed: () => _confirmLogout(authenticationProvider, contentProvider),
                ),
              if (user != null)
                TextButton(
                  onPressed: _confirmDelete,
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.redAccent, decoration: TextDecoration.underline),
                  ),
                ),
              const SizedBox(height: 8),
              Text(_appVersion, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(AuthenticationProvider authenticationProvider, ContentProvider contentProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return LogoutDialog(
          onConfirm: () async {
            await authenticationProvider.logout();
            final loginConfig = contentProvider.getLoginConfigConfirm();
            contentProvider.removeContinueWatching();
            if (!context.mounted) return;
            Navigator.of(context).pop();
            if (loginConfig == 'B' || loginConfig == 'C') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (_) => false,
              );
            }
          },
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.colorSurface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete your account? This cannot be undone and subscriptions are not refunded.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: deleteController,
                hintText: 'Reason For Deletion',
                obscureText: false,
                isLast: true,
                padding: 5,
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                final authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
                NetworkService().post(
                  APIPath.deleteAccount,
                  {"reason": deleteController.text},
                  (data) async {
                    await authenticationProvider.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  (error) {},
                  () {},
                );
              },
              child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
