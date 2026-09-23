import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/media/episode_item.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/pages/authentication/login_screen.dart';
import 'package:cineprime/providers/my_list_provider.dart';
import 'package:cineprime/presentation/pages/media/trailer_player.dart';
import 'package:cineprime/trailer_player_stub.dart' if (dart.library.html) 'package:cineprime/presentation/pages/media/trailer_player_web.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/bottom_sheet/media_bottomsheet.dart';
import '../../../providers/authentication_provider.dart';
import '../../../providers/content_provider.dart';
import '../../../services/deeplinkly_service.dart';

class TvShowDetailsPage extends StatefulWidget {
  final BaseItem baseItem;
  final String? highlightEpisodeId;

  const TvShowDetailsPage(this.baseItem, {super.key, this.highlightEpisodeId});

  @override
  State<TvShowDetailsPage> createState() => _TvShowDetailsPageState();
}

class _TvShowDetailsPageState extends State<TvShowDetailsPage> {
  List<String> seasonList = [];
  List<BaseItem> episodeList = [];
  String selectedItem = "";
  bool _isSharing = false;
  final ScrollController _episodeScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  final GlobalKey _episodesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    seasonList.addAll(
      List.generate(
        widget.baseItem.numberOfSeasons,
        (index) => 'Season ${index + 1}',
      ),
    );
    if (widget.highlightEpisodeId != null) {
      BaseItem? highlightEpisode;
      for (final e in widget.baseItem.episodes) {
        if (e.id == widget.highlightEpisodeId) {
          highlightEpisode = e;
          break;
        }
      }
      if (highlightEpisode != null) {
        selectedItem = 'Season ${highlightEpisode.seasonNumber}';
      } else {
        selectedItem = seasonList.isNotEmpty ? seasonList.first : '';
      }
    } else {
      selectedItem = seasonList.isNotEmpty ? seasonList.first : '';
    }
    if (widget.highlightEpisodeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _scrollToHighlightedEpisode();
        });
      });
    }
  }

  void _scrollToHighlightedEpisode() {
    final context = this.context;
    // First scroll the main page so the Episodes section is visible
    final episodesContext = _episodesSectionKey.currentContext;
    if (episodesContext != null) {
      Scrollable.ensureVisible(
        episodesContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    }
    final contentProvider = Provider.of<ContentProvider>(context, listen: false);
    final series = contentProvider.getMediaById(
      widget.baseItem.id,
      widget.baseItem.mediaType,
    );
    if (series == null || widget.highlightEpisodeId == null) return;
    final seasonNum = selectedItem.split(" ").length > 1 ? selectedItem.split(" ")[1] : null;
    if (seasonNum == null) return;
    final forSeason = series.episodes.where(
      (e) => e.seasonNumber.toString() == seasonNum,
    ).toList();
    final index = forSeason.indexWhere((e) => e.id == widget.highlightEpisodeId);
    if (index < 0) return;
    final screenWidth = MediaQuery.sizeOf(context).width;
    const padding = 32.0;
    const spacing = 8.0;
    final itemWidth = (screenWidth - padding - spacing) / 2;
    final offset = 16.0 + index * (itemWidth + spacing);
    // Scroll horizontal list after the page has scrolled so episodes are in view
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (_episodeScrollController.hasClients) {
        _episodeScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _episodeScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final isLoggedIn = authenticationProvider.getUser() != null;
    final myList = Provider.of<MyListProvider>(context);
    final series = contentProvider.getMediaById(
      widget.baseItem.id,
      widget.baseItem.mediaType,
    );
    final displayItem = series ?? widget.baseItem;
    episodeList.clear();
    if (series != null && selectedItem.isNotEmpty) {
      episodeList.addAll(
        series.episodes.where(
          (episode) => episode.seasonNumber.toString() == selectedItem.split(" ")[1],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
        children: [
          SingleChildScrollView(
        controller: _mainScrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical poster edge to edge with title overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Poster image + bottom spacer so Stack height includes title row (for hit testing)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: displayItem.verticalPosterUrl,
                        fit: BoxFit.fitWidth,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
                // Black gradient at bottom for title visibility
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
                // Title, classification, and age ratings stacked below poster
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        displayItem.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Age rating and classification in same row
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            // Age rating capsule (first item, red)
                            Builder(
                              builder: (context) {
                                String ageText = "";
                                if (displayItem.ageRating != null && displayItem.ageLimit != null) {
                                  ageText = "${displayItem.ageRating} ${displayItem.ageLimit}+";
                                } else if (displayItem.ageRating != null) {
                                  ageText = displayItem.ageRating!;
                                } else if (displayItem.ageLimit != null) {
                                  ageText = "${displayItem.ageLimit}+";
                                }

                                if (ageText.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.colorPrimary.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ageText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Classification as simple text separated by pipe
                            if (displayItem.categories.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                displayItem.categories.map((category) => category.trim()).join(" | "),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const Spacer(),
                            GestureDetector(
                              onTap: _isSharing
                                  ? null
                                  : () async {
                                      setState(() => _isSharing = true);
                                      try {
                                        final url = await DeepLinklyLinkService.instance.generateLink(
                                          context,
                                          type: LinkType.series,
                                          data: {
                                            'slug': widget.baseItem.id,
                                            'title': widget.baseItem.title,
                                            'description': widget.baseItem.description,
                                            'poster': widget.baseItem.verticalPosterUrl,
                                          },
                                        );
                                        if (mounted) Share.share(url);
                                      } finally {
                                        if (mounted) setState(() => _isSharing = false);
                                      }
                                    },
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: _isSharing
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Content below poster (top: 20 keeps same visual gap as original 60 - 40 overflow)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayItem.title, style: AppTextStyles.displayTitle.copyWith(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(mediaMetaLine(displayItem), style: AppTextStyles.meta),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Play',
                          icon: Icons.play_arrow_rounded,
                          onPressed: () {
                            if (episodeList.isNotEmpty) {
                              showBottomSheetOrNavigate(context, episodeList.first);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => myList.toggle(displayItem.id),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.colorSurface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.colorInputBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  myList.contains(displayItem.id) ? Icons.bookmark_rounded : Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'My List',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DetailAction(
                        icon: Icons.star_border_rounded,
                        label: 'Rate',
                        onPressed: () {},
                      ),
                      DetailAction(
                        icon: Icons.ios_share_rounded,
                        label: 'Share',
                        onPressed: () async {
                          setState(() => _isSharing = true);
                          try {
                            final url = await DeepLinklyLinkService.instance.generateLink(
                              context,
                              type: LinkType.series,
                              data: {
                                'slug': widget.baseItem.id,
                                'title': widget.baseItem.title,
                                'description': widget.baseItem.description,
                                'poster': widget.baseItem.verticalPosterUrl,
                              },
                            );
                            if (mounted) Share.share(url);
                          } finally {
                            if (mounted) setState(() => _isSharing = false);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Line separator
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Divider(
                      color: Colors.white24,
                      height: 1,
                    ),
                  ),
                  // "Trailers and extras" text
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      "Trailers and extras",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Horizontal poster (small like media item) - opens trailer player (login required)
                  if (displayItem.trailerUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginPage(next: TvShowDetailsPage(widget.baseItem)),
                              ),
                            );
                            return;
                          }
                          final trailerPlayer = kIsWeb ? TrailerVideoPlayerWeb(displayItem) : TrailerVideoPlayer(displayItem);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => trailerPlayer),
                          );
                        },
                        child: SizedBox(
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: displayItem.horizontalPosterUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F1F1F),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.play_circle, color: Colors.white, size: 50),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F1F1F),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.play_circle, color: Colors.white, size: 50),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Episodes section (keyed so we can scroll to it for deeplink highlight)
            Padding(
              key: _episodesSectionKey,
              padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: const Text(
                "Episodes:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            if (episodeList.isNotEmpty)
              Builder(
                builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final padding = 32.0; // 16px on each side
                  final spacing = 8.0; // spacing between items (matches tile gap)
                  final itemWidth = (screenWidth - padding - spacing) / 2;

                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      controller: _episodeScrollController,
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: episodeList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: itemWidth,
                          margin: EdgeInsets.only(
                            right: index == episodeList.length - 1 ? 8 : spacing,
                          ),
                          child: EpisodeItem(
                            baseItem: episodeList[index],
                            isHighlighted: episodeList[index].id == widget.highlightEpisodeId,
                          ),
                        );
                      },
                    ),
                  );
                },
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 30),
                child: Center(
                  child: Text(
                    "Coming Soon",
                    style: const TextStyle(color: Colors.white60, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            // Separator below episodes
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 24),
              child: Divider(
                color: Colors.white24,
                height: 1,
              ),
            ),
            // Storyline section
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Storyline",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayItem.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Show Detail section
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Show Detail",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cast and Director - each with aligned label and value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cast row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              "Cast:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getCastNames(displayItem),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Director row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 70,
                            child: Text(
                              "Director:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getDirectorName(displayItem),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Separator
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
              child: Divider(
                color: Colors.white24,
                height: 1,
              ),
            ),
            // More like this section
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "More like this",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Suggested series
                  Builder(
                    builder: (context) {
                      final suggestedSeries = _getSuggestedSeries(displayItem, contentProvider);
                      if (suggestedSeries.isEmpty) {
                        return const Text(
                          "No suggestions available",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        );
                      }

                      final screenWidth = MediaQuery.of(context).size.width;
                      final padding = 32.0; // 16px on each side
                      final spacing = 8.0; // spacing between items (matches tile gap)
                      final itemWidth = (screenWidth - padding - spacing) / 2.2; // 2.2 items visible
                      final itemHeight = itemWidth * (3 / 2); // Vertical poster aspect ratio 2:3

                      return SizedBox(
                        height: itemHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          primary: false,
                          physics: const BouncingScrollPhysics(),
                          itemCount: suggestedSeries.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: itemWidth,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == suggestedSeries.length - 1 ? 0 : 8,
                                ),
                                child: MediaItem(
                                  baseItem: suggestedSeries[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 8,
            child: CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 40,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            right: 8,
            child: CircleIconButton(
              icon: myList.contains(displayItem.id) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 40,
              iconColor: myList.contains(displayItem.id) ? AppColors.colorPrimary : Colors.white,
              onPressed: () => myList.toggle(displayItem.id),
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _getCastNames(BaseItem item) {
    if (item.castAndCrew == null || item.castAndCrew!.isEmpty) {
      return "N/A";
    }

    final castGroup = item.castAndCrew!.firstWhere(
      (group) => group.role.toLowerCase() == "cast",
      orElse: () => CastAndCrew(role: "", members: []),
    );

    if (castGroup.members.isEmpty) {
      return "N/A";
    }

    return castGroup.members.map((member) => member.name).join(", ");
  }

  String _getDirectorName(BaseItem item) {
    if (item.castAndCrew == null || item.castAndCrew!.isEmpty) {
      return "N/A";
    }

    final directorGroup = item.castAndCrew!.firstWhere(
      (group) => group.role.toLowerCase() == "director",
      orElse: () => CastAndCrew(role: "", members: []),
    );

    if (directorGroup.members.isEmpty) {
      return "N/A";
    }

    return directorGroup.members.map((member) => member.name).join(", ");
  }

  List<BaseItem> _getSuggestedSeries(BaseItem series, ContentProvider contentProvider) {
    if (series.suggestions.isEmpty) {
      return [];
    }

    final suggestedItems = <BaseItem>[];
    for (final suggestionId in series.suggestions) {
      final suggestedItem = contentProvider.getMediaById(suggestionId, MediaType.series);
      if (suggestedItem != null) {
        suggestedItems.add(suggestedItem);
      }
    }

    return suggestedItems;
  }
}
