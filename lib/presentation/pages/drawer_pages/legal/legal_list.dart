import 'package:cineprime/presentation/pages/drawer_pages/legal/about_us_page.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/components/controls/more_widget.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/grievance.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/privacy_policy_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/refund_policy_page.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/terms_and_conditions_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalListPage extends StatefulWidget {
  const LegalListPage({super.key});

  @override
  State<LegalListPage> createState() => _LegalListPageState();
}

class _LegalListPageState extends State<LegalListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Legal Information'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          MoreWidget(
            text: 'Terms of use',
            icon: Icons.contact_page_outlined,
            onPressed: () {
              if (PlatformUtils.isWeb) {
                _launchURL('https://butterflyott.com/legal/terms');
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsPage(),
                  ),
                );
              }
            },
          ),
          MoreWidget(
            text: 'Privacy policy',
            icon: Icons.privacy_tip_outlined,
            onPressed: () {
              if (PlatformUtils.isWeb) {
                _launchURL('https://butterflyott.com/legal/privacy-policy');
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              }
            },
          ),
          MoreWidget(
            text: 'Refund policy',
            icon: Icons.account_balance_outlined,
            onPressed: () {
              if (PlatformUtils.isWeb) {
                _launchURL('https://butterflyott.com/legal/refund-policy');
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RefundPolicyPage(),
                  ),
                );
              }
            },
          ),
          MoreWidget(
            text: 'About Us',
            icon: Icons.info_outline,
            onPressed: () {
              if (PlatformUtils.isWeb) {
                _launchURL('https://butterflyott.com/legal/refund-policy');
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AboutUsPage(),
                  ),
                );
              }
            },
          ),
          MoreWidget(
            text: 'Grievance Redressal',
            icon: Icons.gavel_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GrievancePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String websiteUrl) async {
    final Uri url = Uri.parse(websiteUrl);
    if (!await launchUrl(url, webOnlyWindowName: '_blank')) {
      throw 'Could not launch $url';
    }
  }
}
