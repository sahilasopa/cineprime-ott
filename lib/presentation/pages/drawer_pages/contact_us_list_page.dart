import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/controls/more_widget.dart';
import 'package:cineprime/presentation/pages/drawer_pages/contact_us_page.dart';

import '../../../services/logging_service.dart';

class ContactUsListPage extends StatefulWidget {
  const ContactUsListPage({super.key});

  @override
  State<ContactUsListPage> createState() => _ContactUsListPageState();
}

class _ContactUsListPageState extends State<ContactUsListPage> {
  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("contact_us_list_page");
    LoggingService().setCrashlyticsScreen("contact_us_list_page");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Tap an option below for more info',
              style: AppTextStyles.meta,
            ),
          ),
          MoreWidget(
            text: 'Concern / Queries',
            icon: Icons.contact_page_outlined,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ContactUsPage(),
              ));
            },
          ),
          MoreWidget(
            text: 'Help / Support',
            icon: Icons.support_agent_rounded,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ContactUsPage(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
