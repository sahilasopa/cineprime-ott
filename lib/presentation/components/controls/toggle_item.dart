import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

class ToggleSwitchWidget extends StatelessWidget {
  final String text;
  final IconData icon;

  const ToggleSwitchWidget({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.20), // dark frosted fill
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.colorPrimary.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(text,
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                  const Spacer(),
                  CupertinoSwitch(
                    value: contentProvider.showChildSafe,
                    onChanged: (value) {
                      contentProvider.toggleSwitch();
                    },
                    inactiveTrackColor: Colors.grey,
                    activeTrackColor: AppColors.colorPrimary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
