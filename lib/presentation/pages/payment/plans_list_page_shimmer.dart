import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/subscription/plan_card.dart';

class PlansListPageShimmer extends StatelessWidget {
  const PlansListPageShimmer({super.key});

  static const _shimmerBase = Color(0xFF1A1A24);
  static const _shimmerHighlight = Color(0xFF2A2A36);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PlansPageHeader(),
          const SizedBox(height: 18),
          Shimmer.fromColors(
            baseColor: _shimmerBase,
            highlightColor: _shimmerHighlight,
            child: Column(
              children: [
                _ticket(),
                const SizedBox(height: 14),
                _ticket(),
                const SizedBox(height: 14),
                _ticket(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticket() {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: AppColors.colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.colorInputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            decoration: const BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(19)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: _shimmerBase,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: 90,
                    decoration: BoxDecoration(
                      color: _shimmerBase,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 18,
                    width: 72,
                    decoration: BoxDecoration(
                      color: _shimmerBase,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
