import 'package:flutter/material.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/notification.dart';
import 'package:cineprime/presentation/components/notification_item.dart';
import 'package:cineprime/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<InAppNotificationProvider>(context);
    final List<NotificationModel> notifications =
        notificationProvider.getNotifications();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No new notifications',
                subtitle: 'News about our latest releases will show up here.',
              )
            // List of real notifications
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return NotificationItem(
                    notification: notifications[index],
                  );
                },
              ),
      ),
    );
  }
}
