import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/controls/more_widget.dart';
import 'package:cineprime/presentation/components/logout_dialog.dart';
import 'package:cineprime/presentation/pages/drawer_pages/profile_page.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/contact_us_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/privacy_policy_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/terms_and_conditions_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/refund_policy_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/about_us_page.dart';
import 'package:cineprime/models/user/user.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/presentation/pages/authentication/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoreInfoPage extends StatefulWidget {
  const MoreInfoPage({super.key});

  @override
  State<MoreInfoPage> createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  String _appVersion = '';
  String _timing = 'Mon - Sat, 10:00 AM - 6:00 PM IST'; // Replace with actual timing

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);
    final user = authenticationProvider.getUser();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Card with Logo and Phone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.colorBackground.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.colorPrimary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/cineprime-logo.png",
                        height: 60,
                      ),
                      // Only show phone/email when logged in
                      if (user != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _getUserContactInfo(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // List of Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    // Sign In Button (only when logged out)
                    if (user == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: GestureDetector(
                            onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: AppColors.primaryGradient,
                            ),
                            child: const Center(
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Only show these when logged out
                    if (user == null) ...[
                      MoreWidget(
                        text: "Subscription",
                        svgIconPath: 'assets/images/icons/subscription.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PlansListPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Privacy Policy",
                        svgIconPath: 'assets/images/icons/privacy.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Terms and Conditions",
                        svgIconPath: 'assets/images/icons/terms.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Refund Policy",
                        svgIconPath: 'assets/images/icons/refund.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RefundPolicyPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "About Us",
                        svgIconPath: 'assets/images/icons/about.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      // Show all items when logged in
                      MoreWidget(
                        text: "Profile",
                        svgIconPath: 'assets/images/icons/profile.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Subscription",
                        svgIconPath: 'assets/images/icons/subscription.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PlansListPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Help and Support",
                        icon: Icons.help_outline,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ContactUsPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Privacy Policy",
                        svgIconPath: 'assets/images/icons/privacy.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Terms and Conditions",
                        svgIconPath: 'assets/images/icons/terms.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Refund Policy",
                        svgIconPath: 'assets/images/icons/refund.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RefundPolicyPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "About Us",
                        svgIconPath: 'assets/images/icons/about.svg',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),
                      MoreWidget(
                        text: "Rate Us",
                        icon: FontAwesomeIcons.rankingStar.data,
                        onPressed: () {
                          InAppReview.instance.openStoreListing();
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.7),
                        builder: (BuildContext context) {
                          return LogoutDialog(
                            onConfirm: () async {
                              await authenticationProvider.logout();
                              final loginConfig = contentProvider.getLoginConfigConfirm();
                              contentProvider.removeContinueWatching();
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              if (loginConfig == 'B' || loginConfig == 'C') {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                  (_) => false,
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // Footer - Get in Touch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.colorBackground.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.colorPrimary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Get in Touch",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (contentProvider.getSupportEmail().isNotEmpty)
                        _buildContactRow(Icons.email, "Email:", contentProvider.getSupportEmail(), isClickable: true),
                      if (contentProvider.getSupportEmail().isNotEmpty && contentProvider.getSupportPhoneNumber().isNotEmpty)
                        const SizedBox(height: 12),
                      if (contentProvider.getSupportPhoneNumber().isNotEmpty)
                        _buildContactRow(Icons.phone, "Phone:", contentProvider.getSupportPhoneNumber(), isClickable: true),
                      if (contentProvider.getSupportPhoneNumber().isNotEmpty)
                        const SizedBox(height: 12),
                      _buildContactRow(Icons.access_time, "Timing:", _timing, isClickable: false),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // App Version
              Text(
                _appVersion,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, {bool isClickable = false}) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.colorPrimary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' $value',
                  style: TextStyle(
                    color: isClickable ? AppColors.colorPrimary : Colors.white70,
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isClickable) {
      return GestureDetector(
        onTap: () async {
          if (icon == Icons.email) {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: value,
            );
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            }
          } else if (icon == Icons.phone) {
            final Uri phoneUri = Uri(
              scheme: 'tel',
              path: value.replaceAll(RegExp(r'[^\d+]'), ''),
            );
            if (await canLaunchUrl(phoneUri)) {
              await launchUrl(phoneUri);
            }
          }
        },
        child: content,
      );
    }

    return content;
  }

  String _getUserContactInfo(User? user) {
    if (user == null) {
      return '+91 1234567890'; // Default dummy number when logged out
    }
    
    // Return user's contact number if available
    if (user.contactNumber != null && user.contactNumber!.isNotEmpty) {
      return user.contactNumber!;
    }
    
    // Otherwise return user's email if available
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!;
    }
    
    // Fallback to dummy number
    return '+91 1234567890';
  }
}

