import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

class GrievancePage extends StatelessWidget {
  const GrievancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Grievance Redressal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'If you have any grievances related to a title currently available in India or its age ratings, title, descriptions, synopses, content advisories or tags, or parental control features, you can raise a content grievance with our Grievance Redressal Officer using the details below.',
            style: TextStyle(
              color: AppColors.colorTextSecondary,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Officer details', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                Text(
                  'Name: ${contentProvider.getGrievanceName()}',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${contentProvider.getGrievanceEmail()}',
                  style: const TextStyle(color: AppColors.colorPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
