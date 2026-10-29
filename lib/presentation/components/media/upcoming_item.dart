import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/bottom_sheet/media_bottomsheet.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:shimmer/shimmer.dart';

String _firstLine(String description) {
  if (description.isEmpty) return '';
  final first = description.split('\n').first.trim();
  return first;
}

class UpcomingItem extends StatelessWidget {
  final BaseItem baseItem;

  const UpcomingItem({super.key, required this.baseItem});

  @override
  Widget build(BuildContext context) {
    final isExternal = baseItem.mediaType == MediaType.external &&
        baseItem.externalUrl != null &&
        baseItem.externalUrl!.trim().isNotEmpty;

    void onTap() {
      if (isExternal) {
        handleExternalItemTap(baseItem);
        return;
      }
      showBottomSheetOrNavigate(context, baseItem);
    }

    final subtitleText = isExternal
        ? _firstLine(baseItem.description)
        : (baseItem.description.isNotEmpty
            ? baseItem.description
            : baseItem.getReleaseDate());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // text aligned left
          children: [
            AspectRatio(
              aspectRatio: 1, // square image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MediaItem(
                  baseItem: baseItem,
                  imageUrl: baseItem.squarePosterUrl,
                  onTap: onTap,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baseItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.colorPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitleText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitleText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  label: 'Play',
                  button: true,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onTap,
                      child: Center(
                        child: Image.asset(
                          'assets/images/icons/play.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer colors aligned with [ShimmerTile] / [ShimmerMediaItem] and the rest of the app.
const _shimmerBase = Color(0xFF1F1F1F);
final _shimmerHighlight = Colors.grey[800]!;

class UpcomingItemShimmer extends StatelessWidget {
  const UpcomingItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square poster placeholder (matches UpcomingItem aspect ratio 1)
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Shimmer.fromColors(
                baseColor: _shimmerBase,
                highlightColor: _shimmerHighlight,
                child: Container(
                  color: _shimmerBase,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: _shimmerBase,
                      highlightColor: _shimmerHighlight,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: _shimmerBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: _shimmerBase,
                      highlightColor: _shimmerHighlight,
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _shimmerBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: _shimmerBase,
                      highlightColor: _shimmerHighlight,
                      child: Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: _shimmerBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: Shimmer.fromColors(
                  baseColor: _shimmerBase,
                  highlightColor: _shimmerHighlight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _shimmerBase,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
