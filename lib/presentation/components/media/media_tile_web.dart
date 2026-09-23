import 'package:flutter/material.dart';
import 'package:cineprime/models/media/section.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/presentation/pages/fragments/search_page.dart';
import 'package:shimmer/shimmer.dart';

class MediaTileWeb extends StatelessWidget {
  final Section section;

  const MediaTileWeb(this.section, {super.key});

  Widget _buildSectionHeader(BuildContext context, {bool showViewAll = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 4, left: 8),
          child: Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showViewAll)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(section: section),
              ));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 4, right: 10),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF181818),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height * 0.22;
    if (section.baseItems.isEmpty) {
      return Container();
    }

    // horizontal_single: single large item
    if (section.type == 'horizontal_single') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, showViewAll: false),
          SizedBox(
            height: MediaQuery.of(context).size.width * (9 / 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemHorizontalSingle(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // horizontal_large: 1 item scrollable (full width)
    if (section.type == 'horizontal_large') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight * 1.8,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemHorizontalLarge(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // horizontal: 2.5 items on viewport
    if (section.type == 'horizontal') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemHorizontal(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // horizontal_small: 2 items on viewport
    if (section.type == 'horizontal_small') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight * 1.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemHorizontal(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // square: 2 square items on viewport
    if (section.type == 'square') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight * 1.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemSquare(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // square_large: 1 square item on viewport
    if (section.type == 'square_large') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight * 2.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemSquare(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // square_small: 3 square items on viewport
    if (section.type == 'square_small') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight * 1.2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItemSquare(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // vertical_large: exactly 2 items on viewport
    if (section.type == 'vertical_large') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight * 1.4,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItem(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // vertical: 2.5 items on viewport
    if (section.type == 'vertical') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: containerHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                  child: MediaItem(baseItem: section.baseItems[index]),
                );
              },
            ),
          ),
        ],
      );
    }

    // vertical_small (default): 3 items on viewport
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        SizedBox(
          height: containerHeight * 0.9,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 8),
                child: MediaItem(baseItem: section.baseItems[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShimmerTile extends StatelessWidget {
  const ShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height * 0.22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 5, left: 10),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF1F1F1F),
              highlightColor: Colors.grey[800]!,
              child: Container(
                width: 200,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )),
        SizedBox(
          height: containerHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShimmerTileHorizontal extends StatelessWidget {
  const ShimmerTileHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height * 0.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 5, left: 10),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF1F1F1F),
              highlightColor: Colors.grey[800]!,
              child: Container(
                width: 200,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )),
        SizedBox(
          height: containerHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
