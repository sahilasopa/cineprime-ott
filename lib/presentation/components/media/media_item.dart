import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:provider/provider.dart';
import '../bottom_sheet/media_bottomsheet.dart';

class MediaItem extends StatelessWidget {
  final BaseItem baseItem;
  final bool replacement;
  final String imageUrl;
  final VoidCallback? onTap;

  const MediaItem({
    super.key,
    required this.baseItem,
    this.replacement = false,
    this.imageUrl = "",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String localUrl = imageUrl;
    double aspectRatio = 1.0;
    if (imageUrl == "") {
      localUrl = baseItem.verticalPosterUrl;
      aspectRatio = 2.0 / 3.0;
    }
    final double progress =
        baseItem.getPercentageWatched(); // value between 0.0 and 1.0

    return GestureDetector(
      onTap: () {
        (onTap ?? () => showBottomSheetOrNavigate(context, baseItem))();
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: localUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Free badge
          if (!baseItem.isPremium)
            Positioned(
              top: 5,
              left: -16,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  color: AppColors.colorPrimaryLight,
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Progress bar at bottom
          if (progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.colorPrimary),
                  minHeight: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaItemHorizontal extends StatelessWidget {
  final BaseItem baseItem;
  final bool replacement;
  final bool isContinueWatching;

  const MediaItemHorizontal({
    super.key,
    required this.baseItem,
    this.replacement = false,
    this.isContinueWatching = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        baseItem.getPercentageWatched(); // Value between 0.0 and 1.0

    return GestureDetector(
      onTap: () {
        showBottomSheetOrNavigate(context, baseItem);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: baseItem.horizontalPosterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Free badge
          if (!baseItem.isPremium)
            Positioned(
              top: 5,
              left: -16,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  color: AppColors.colorPrimaryLight,
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Progress bar at bottom
          if (progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.colorPrimary),
                  minHeight: 4,
                ),
              ),
            ),
          if (isContinueWatching)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () {
                  Provider.of<ContentProvider>(context, listen: false)
                      .removeFromContinueWatching(baseItem);
                  NetworkService().post(
                    APIPath.removeContinueWatching,
                    {
                      "content_id": baseItem.id,
                    },
                    (data) {},
                    (error) {},
                    () {},
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaItemHorizontalSingle extends StatelessWidget {
  final BaseItem baseItem;
  final bool replacement;

  const MediaItemHorizontalSingle({
    super.key,
    required this.baseItem,
    this.replacement = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = baseItem.getPercentageWatched();

    return GestureDetector(
      onTap: () {
        showBottomSheetOrNavigate(context, baseItem);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: baseItem.horizontalPosterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Free badge
          if (!baseItem.isPremium)
            Positioned(
              top: 5,
              left: -16,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  color: AppColors.colorPrimaryLight,
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom progress bar
          if (progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.colorPrimary),
                  minHeight: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaItemSquare extends StatelessWidget {
  final BaseItem baseItem;
  final bool replacement;

  const MediaItemSquare({
    super.key,
    required this.baseItem,
    this.replacement = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = baseItem.getPercentageWatched();
    // Use square poster URL, fallback to vertical poster
    final String imageUrl = baseItem.squarePosterUrl.isNotEmpty
        ? baseItem.squarePosterUrl
        : baseItem.verticalPosterUrl;

    return GestureDetector(
      onTap: () {
        showBottomSheetOrNavigate(context, baseItem);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: 1.0, // Square aspect ratio
              child: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Free badge
          if (!baseItem.isPremium)
            Positioned(
              top: 5,
              left: -16,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  color: AppColors.colorPrimaryLight,
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Progress bar at bottom
          if (progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.colorPrimary),
                  minHeight: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaItemHorizontalLarge extends StatelessWidget {
  final BaseItem baseItem;
  final bool replacement;

  const MediaItemHorizontalLarge({
    super.key,
    required this.baseItem,
    this.replacement = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = baseItem.getPercentageWatched();

    return GestureDetector(
      onTap: () {
        showBottomSheetOrNavigate(context, baseItem);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                imageUrl: baseItem.horizontalPosterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/cineprime-icon.png",
                      width: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Free badge
          if (!baseItem.isPremium)
            Positioned(
              top: 5,
              left: -16,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  color: AppColors.colorPrimaryLight,
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Progress bar at bottom
          if (progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.colorPrimary),
                  minHeight: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ShimmerMediaItem extends StatelessWidget {
  const ShimmerMediaItem({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Image.asset(
            "assets/images/cineprime-icon.png",
            width: 100,
          ),
        ),
      ),
    );
  }
}
