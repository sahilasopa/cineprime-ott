import 'package:flutter/material.dart';
import 'package:cineprime/presentation/pages/drawer_pages/legal/policy_content_page.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    return PolicyContentPage(
      title: 'Refund Policy',
      getContent: () => contentProvider.getRefundPolicy(),
    );
  }
}
