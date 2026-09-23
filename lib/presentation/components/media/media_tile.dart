import 'package:flutter/material.dart';
import 'package:cineprime/models/media/section.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/presentation/pages/fragments/search_page.dart';
import 'package:shimmer/shimmer.dart';

const double _verticalCardHorizontalPadding = 4.0;

class MediaTile extends StatelessWidget {
  final Section section;

  const MediaTile(this.section, {super.key});

  Widget _buildSectionHeader(BuildContext context, {bool showViewAll = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              section.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.w800,
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
              child: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (section.baseItems.isEmpty) {
      return Container();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // horizontal_single: single large item (no scroll)
    if (section.type == 'horizontal_single') {
      return Container(
        margin: EdgeInsetsGeometry.symmetric(horizontal: 5),
        child: MediaItemHorizontalSingle(baseItem: section.baseItems[0]),
      );
    }

    // horizontal_large: 1 item scrollable (full width with padding)
    if (section.type == 'horizontal_large') {
      final itemWidth = screenWidth - 12; // Full width with small padding
      final itemHeight = itemWidth * (9 / 16);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItemHorizontalLarge(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // horizontal: 2.5 items on viewport
    if (section.type == 'horizontal') {
      final itemWidth = screenWidth / 2.5;
      final itemHeight = itemWidth * (9 / 16);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItemHorizontal(
                      baseItem: section.baseItems[index],
                      isContinueWatching: section.isContinueWatching,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // horizontal_small: 2 items on viewport
    if (section.type == 'horizontal_small') {
      final itemWidth = screenWidth / 2;
      final itemHeight = itemWidth * (9 / 16);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItemHorizontal(
                      baseItem: section.baseItems[index],
                      isContinueWatching: section.isContinueWatching,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // square: 2 square items on viewport
    if (section.type == 'square') {
      final itemWidth = screenWidth / 2;
      final itemHeight = itemWidth; // Square aspect ratio

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItemSquare(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // square_large: 1 square item on viewport
    if (section.type == 'square_large') {
      final itemWidth = screenWidth - 12; // Full width with padding
      final itemHeight = itemWidth; // Square aspect ratio

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItemSquare(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // square_small: 3 square items on viewport
    if (section.type == 'square_small') {
      final itemWidth = screenWidth / 3;
      final itemHeight = itemWidth; // Square aspect ratio

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItemSquare(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // vertical_large: exactly 2 items on viewport
    if (section.type == 'vertical_large') {
      final itemWidth = screenWidth / 2;
      final itemHeight = (itemWidth - 2 * _verticalCardHorizontalPadding) * (3 / 2);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItem(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // vertical: 2.5 items on viewport
    if (section.type == 'vertical') {
      final itemWidth = screenWidth / 2.5;
      final itemHeight = (itemWidth - 2 * _verticalCardHorizontalPadding) * (3 / 2);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItem(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // vertical_small (default): 3 items on viewport
    {
      final itemWidth = screenWidth / 3;
      final itemHeight = (itemWidth - 2 * _verticalCardHorizontalPadding) * (3 / 2);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: section.baseItems.length > 10 ? 10 : section.baseItems.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _verticalCardHorizontalPadding),
                    child: MediaItem(baseItem: section.baseItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/cineprime-icon.png",
                        width: 80,
                      ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/cineprime-icon.png",
                        width: 100,
                      ),
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
