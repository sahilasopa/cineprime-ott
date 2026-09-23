import 'package:flutter/material.dart';

class SubscriptionBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Keeps it compact
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns text properly
        children: [
          SizedBox(height: 10),
          _buildBulletPoint("New web series release every week"),
          SizedBox(height: 3),
          _buildBulletPoint("Unlimited streaming"),
          SizedBox(height: 3),
          _buildBulletPoint("HD + (2k) Quality"),
          SizedBox(height: 3),
          _buildBulletPoint("Get full access to all premium content"),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Keeps row compact
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.circle, size: 6, color: Colors.white),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: "Garet"),
        ),
      ],
    );
  }
}

class InfoHighlightsRow extends StatelessWidget {
  const InfoHighlightsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem("👥 200k+ Users Already Subscribed"),
          _buildItem("🔒 Secure Payments"),
          _buildItem("⏰ Hurry up! Offer ends in 24 hours"),
        ],
      ),
    );
  }

  Widget _buildItem(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.4,
          ),
          softWrap: true,
        ),
      ),
    );
  }
}
