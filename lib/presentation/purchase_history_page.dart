import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/user/user_subscription.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<UserSubscription>> _purchaseHistoryFuture;

  @override
  void initState() {
    super.initState();
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _purchaseHistoryFuture = authenticationProvider.getPurchaseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Purchase History'),
      ),
      body: FutureBuilder<List<UserSubscription>>(
        future: _purchaseHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerPlaceholder();
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load history',
              subtitle: 'Please try again in a moment.',
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No purchase history',
              subtitle: 'Plans you subscribe to will show up here.',
            );
          }

          final purchases = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              return _buildSubscriptionCard(purchases[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(UserSubscription purchase) {
    return SurfaceCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(purchase.planName, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text('Status: ${purchase.status}', style: AppTextStyles.meta),
          const SizedBox(height: 4),
          Text('Order ID: ${purchase.orderId}', style: AppTextStyles.meta),
          const SizedBox(height: 4),
          Text('Valid from: ${purchase.getDisplayStartTime()}', style: AppTextStyles.meta),
          const SizedBox(height: 4),
          Text('Valid until: ${purchase.getDisplayEndTime()}', style: AppTextStyles.meta),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.colorSurface,
          highlightColor: AppColors.colorSurfaceElevated,
          child: Container(
            height: 118,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.colorSurface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
