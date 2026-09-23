import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cineprime/models/media/download_item_wrapper.dart';
import 'package:cineprime/presentation/components/bottom_sheet/download_bottomsheet.dart';
import 'package:cineprime/presentation/pages/media/offline_video_player.dart';

class DownloadedMediaItem extends StatelessWidget {
  final DownloadItemWrapper wrapper;

  const DownloadedMediaItem({super.key, required this.wrapper});

  void _handleTap(BuildContext context) {
    if (wrapper.downloadedBaseItem.progress == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OfflineVideoDetailsPage(wrapper),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => DownloadBottomSheetWidget(
          baseItemId: wrapper.downloadedBaseItem.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unified layout: Poster on left, title and description on right
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Poster on the left (40% of width)
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(
                    File(wrapper.downloadedBaseItem.posterPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title and description on the right (60% of width)
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      wrapper.downloadedBaseItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wrapper.downloadedBaseItem.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
