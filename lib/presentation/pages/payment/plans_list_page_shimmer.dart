import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PlansListPageShimmer extends StatelessWidget {
  const PlansListPageShimmer({super.key});

  static const _shimmerBase = Color(0xFF1A1A24);
  static const _shimmerHighlight = Color(0xFF2A2A36);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          _block(width: 156, height: 28),
          const SizedBox(height: 10),
          _block(width: 168, height: 14),
          const SizedBox(height: 16),
          _block(width: 240, height: 12),
          const SizedBox(height: 18),
          Expanded(
            child: Column(
              children: [
                _card(),
                const SizedBox(height: 10),
                _card(),
                const SizedBox(height: 10),
                _card(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _block(width: 110, height: 14),
          const SizedBox(height: 12),
          Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _shimmerBase,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: _block(width: 96, height: 10),
          ),
        ],
      ),
    );
  }

  Widget _block({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _shimmerBase,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _card() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _shimmerBase,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF242430),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _block(width: 120, height: 14),
                const SizedBox(height: 8),
                _block(width: 72, height: 10),
              ],
            ),
          ),
          _block(width: 56, height: 16),
        ],
      ),
    );
  }
}
