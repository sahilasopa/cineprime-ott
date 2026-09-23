import 'package:flutter/material.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/policy_content_page.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    return PolicyContentPage(
      title: 'About Us',
      getContent: () => contentProvider.getAboutUs(),
    );
  }
}





