import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/bottom_sheet/media_bottomsheet.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/providers/my_list_provider.dart';
import 'package:provider/provider.dart';

class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  List<BaseItem> _resolveItems(ContentProvider content, List<String> ids) {
    final items = <BaseItem>[];
    for (final id in ids) {
      final movie = content.getMediaById(id, MediaType.movie);
      final series = content.getMediaById(id, MediaType.series);
      final item = movie ?? series ?? content.getMediaById(id);
      if (item != null) items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final myList = Provider.of<MyListProvider>(context);
    final saved = _resolveItems(contentProvider, myList.ids);
    final upcoming = contentProvider.getUpcoming();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My List'),
      ),
      body: saved.isEmpty && upcoming.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_add_outlined,
              title: 'Your list is empty',
              subtitle: 'Save titles from a details page to watch them later.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (saved.isNotEmpty) ...[
                  const SectionHeader(title: 'Saved'),
                  for (final item in saved) _TitleCard(item: item),
                ],
                if (upcoming.isNotEmpty) ...[
                  const SectionHeader(title: 'Coming Soon'),
                  for (final item in upcoming) _TitleCard(item: item),
                ],
              ],
            ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  final BaseItem item;

  const _TitleCard({required this.item});

  String get _poster {
    if (item.verticalPosterUrl.isNotEmpty) return item.verticalPosterUrl;
    if (item.squarePosterUrl.isNotEmpty) return item.squarePosterUrl;
    return item.horizontalPosterUrl;
  }

  @override
  Widget build(BuildContext context) {
    final meta = mediaMetaLine(item);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GestureDetector(
        onTap: () => showBottomSheetOrNavigate(context, item),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.colorSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.colorInputBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 104,
                  child: _poster.isEmpty
                      ? const ColoredBox(
                          color: Color(0xFF1F1F1F),
                          child: Icon(Icons.movie_outlined, color: Colors.white54),
                        )
                      : CachedNetworkImage(
                          imageUrl: _poster,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration.zero,
                          placeholder: (_, __) => const ColoredBox(color: Color(0xFF1F1F1F)),
                          errorWidget: (_, __, ___) => const ColoredBox(
                            color: Color(0xFF1F1F1F),
                            child: Icon(Icons.movie_outlined, color: Colors.white54),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? 'Untitled' : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.meta,
                      ),
                    ],
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.colorTextSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
