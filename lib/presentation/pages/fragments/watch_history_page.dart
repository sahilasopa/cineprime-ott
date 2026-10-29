import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

class WatchHistoryPage extends StatelessWidget {
  const WatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _watchHistory(Provider.of<ContentProvider>(context));

    final screenWidth = MediaQuery.sizeOf(context).width;
    final itemWidth = screenWidth / 2.5;
    final itemHeight = itemWidth * (9 / 16);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Watch History'),
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.history_rounded,
              title: 'No watch history',
              subtitle: 'Titles you start will show up here.',
            )
          : Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: itemHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: MediaItemHorizontal(
                            baseItem: items[index],
                            isContinueWatching: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

List<BaseItem> _watchHistory(ContentProvider content) {
  final seen = <String>{};
  final items = <BaseItem>[];

  void add(BaseItem item) {
    if (seen.add(item.id)) items.add(item);
  }

  for (final section in content.getSections()) {
    final title = section.title.toLowerCase();
    if (!section.isContinueWatching && !title.contains('continue')) continue;
    for (final item in section.baseItems) {
      add(item);
    }
  }
  if (items.isNotEmpty) return items;

  void collect(Iterable<BaseItem> list) {
    for (final item in list) {
      final stamp = item.lastTimestamp;
      if (stamp != null && stamp > 0) add(item);
      if (item.episodes.isNotEmpty) collect(item.episodes);
    }
  }

  collect(content.getMovies());
  collect(content.getSeries());
  collect(content.getUpcoming());
  return items;
}

