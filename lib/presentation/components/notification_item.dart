// presentation/components/notification_item.dart

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/pages/media/movie_details_page.dart';
import 'package:cineprime/presentation/pages/media/tv_show_details_page.dart';
import 'package:cineprime/episode_player_stub.dart' if (dart.library.html) 'package:cineprime/presentation/pages/media/episode_player_page_web.dart';
import 'package:cineprime/presentation/pages/media/episode_player_page.dart';
import 'package:flutter/foundation.dart';

import '../../models/notification.dart';
import 'package:cineprime/constants/colors.dart';

class NotificationItem extends StatefulWidget {
  final NotificationModel notification;

  const NotificationItem({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool get _isMediaType =>
      widget.notification.type == NotificationType.newRelease ||
      widget.notification.type == NotificationType.trailer;

  Color get _typeColor {
    switch (widget.notification.type) {
      case NotificationType.subscription:
        return AppColors.colorPrimaryDark;
      case NotificationType.newRelease:
        return AppColors.colorPrimary;
      case NotificationType.trailer:
        return AppColors.colorAccent;
      case NotificationType.info:
        return AppColors.colorTextSecondary;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: GestureDetector(
          onTap: () {
            if (_isMediaType && widget.notification.baseItem != null) {
              final baseItem = widget.notification.baseItem;
              if (baseItem!.mediaType == MediaType.movie) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MovieDetailsPage(baseItem),
                ));
              } else if (baseItem.mediaType == MediaType.series) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TvShowDetailsPage(baseItem),
                ));
              } else if (baseItem.mediaType == MediaType.episode) {
                // Use web player on web, native elsewhere
                final widget = kIsWeb
                    ? EpisodePlayerPageWeb(baseItem)
                    : EpisodePlayerPage(baseItem);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => widget,
                ));
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.colorSurface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // colored type indicator bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: _typeColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // content depending on type
                Expanded(
                  child: _isMediaType && widget.notification.baseItem != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: widget
                                    .notification.baseItem!.horizontalPosterUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: double.infinity,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Image.asset(
                                  'assets/images/cineprime-icon.png',
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // title
                            Text(
                              widget.notification.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.notification.time != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.notification.time!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (widget.notification.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.notification.description!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // small icon/image
                            _NotificationImage(
                              imageUrl: widget.notification.image,
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 12),
                            // title + time + optional description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.notification.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (widget.notification.time != null)
                                        Text(
                                          widget.notification.time!,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (widget.notification.description != null)
                                    Text(
                                      widget.notification.description!,
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _NotificationImage({
    required this.imageUrl,
    this.width = 40,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    if (isNetwork) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        errorWidget: (_, __, ___) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/cineprime-icon.png',
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
