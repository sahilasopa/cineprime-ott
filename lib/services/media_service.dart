import 'package:collection/collection.dart';
import 'package:cineprime/models/media/reel_item.dart';

import '../models/media/media_item.dart';
import '../models/media/section.dart';
import '../network/api_paths.dart';
import '../providers/content_provider.dart';
import 'network_service.dart';

class MediaService {
  MediaService._privateConstructor();

  static final MediaService _instance = MediaService._privateConstructor();

  static MediaService get instance => _instance;

  final List<BaseItem> _upcoming = [];
  final List<BaseItem> _posters = [];
  List<BaseItem> _movies = [];
  List<BaseItem> _series = [];
  List<BaseItem> _externalItems = [];
  List<Section> _sections = [];
  final List<ReelItem> _reels = [];
  Status? _status;
  String _supportPhoneNumber = "";
  String _grievanceEmail = "";
  String _grievanceName = "";
  String _supportEmail = "";
  String _supportTiming = "";
  String _alertTitle = "";
  String _alertMessage = "";

  String _shareText = "Check Out Cineprime";
  String _shareUrl = "https://butterflyott.com";

  String _referralText =
      "Hey! I just installed the Cineprime app and found the video content super entertaining. If you're signing up, make sure to use my code during checkout to get a special bonus! {code}";
  String? _referralVideoUrl;
  String? _referralPosterUrl;

  Future<void> init(void Function() onSuccess, {bool isChildSafe = false}) async {
    if (_status == Status.fetching) return;
    _status = Status.fetching;
    final stopwatch = Stopwatch()..start();

    _upcoming.clear();
    _movies.clear();
    _series.clear();
    _externalItems.clear();
    _sections.clear();
    _posters.clear();

    try {
      await NetworkService().get(APIPath.getSectionHomepage, (data) {
        final mediaResponse = data['body']['content'];
        if (mediaResponse == null) return;
        stopwatch.stop();
        print('API responded in ${stopwatch.elapsedMilliseconds} ms');

        // Contact details
        final contactDetails = mediaResponse["contact_details"];
        _supportPhoneNumber = contactDetails['phone_number'] ?? "";
        _supportEmail = contactDetails['email'] ?? "";
        _supportTiming = contactDetails['timing'] ?? "";
        _grievanceEmail = contactDetails['grievance_email'] ?? "";
        _grievanceName = contactDetails['grievance_name'] ?? "";
        _alertTitle = contactDetails['alert_title'] ?? "";
        _alertMessage = contactDetails['alert_message'] ?? "";

        final shareDetails = mediaResponse["share"];
        _shareText = shareDetails['share_text'];
        _shareUrl = shareDetails['share_url'];

        final referralDetails = mediaResponse["referral"];
        _referralVideoUrl = referralDetails['video_url'];
        _referralPosterUrl = referralDetails['poster_url'];
        _referralText = referralDetails['referral_text'];
        _movies = (mediaResponse["movies"] as List).map((data) => BaseItem.fromJson(data)).toList();
        _series = (mediaResponse["series"] as List).map((data) => BaseItem.fromJson(data)).toList();
        final externalItemsRaw = mediaResponse["external_items"];
        _externalItems = (externalItemsRaw is List)
            ? (externalItemsRaw).map((data) => BaseItem.fromJson(data)).toList()
            : <BaseItem>[];
        final movieMap = {for (var m in _movies) m.id: m};
        final seriesMap = {for (var s in _series) s.id: s};
        final externalItemMap = {for (var e in _externalItems) e.id: e};
        final episodeMap = {
          for (var s in _series)
            for (var e in s.episodes) e.id: e
        };

        // Parse continue watching
        final continueWatching = mediaResponse['continue_watching'];
        final items = continueWatching['items'];
        final List<String> continueIds = [];

        if (items is List) {
          for (final item in items) {
            final id = item['id'];
            final timestamp = item['timestamp_seconds'];
            continueIds.add(id);

            if (episodeMap.containsKey(id)) {
              episodeMap[id]!.lastTimestamp = timestamp;
            } else if (movieMap.containsKey(id)) {
              movieMap[id]!.lastTimestamp = timestamp;
            }
          }
        }

        // Prepare sections (add continueWatching early)
        final rawSections = List<Map<String, dynamic>>.from(mediaResponse["sections"]);
        
        // Only insert continueWatching if there are items
        if (continueIds.isNotEmpty) {
          final insertPosition = continueWatching['priority'] ?? 0;
          rawSections.insert(insertPosition.clamp(0, rawSections.length), {
            "title": continueWatching['title'],
            "priority": continueWatching['priority'] ?? 0,
            "type": continueWatching['type'],
            "item_ids": continueIds,
            "is_continue_watching": true,
          });
        }

        _sections = rawSections
            .map((data) {
              final section = Section.fromJson(data);
              // Map display items (for homepage)
              section.baseItems = section.itemIds.map((itemId) => movieMap[itemId] ?? seriesMap[itemId] ?? episodeMap[itemId] ?? externalItemMap[itemId]).whereType<BaseItem>().toList();
              // Map all items (for "view all")
              section.allBaseItems = section.allItemIds.map((itemId) => movieMap[itemId] ?? seriesMap[itemId] ?? episodeMap[itemId] ?? externalItemMap[itemId]).whereType<BaseItem>().toList();
              return section;
            })
            .where((section) => section.baseItems.isNotEmpty || section.allBaseItems.isNotEmpty)
            .toList();

        // First section posters
        if (_sections.isNotEmpty) {
          _posters.addAll(_sections.first.baseItems);
        }

        // Upcoming: use backend order when provided, otherwise merge and sort by priority
        final upcomingOrderRaw = mediaResponse['upcoming_order'];
        if (upcomingOrderRaw is List && upcomingOrderRaw.isNotEmpty) {
          final orderIds = upcomingOrderRaw.map((e) => e?.toString() ?? '').where((id) => id.isNotEmpty).toList();
          final movieMapUp = {for (var m in _movies) m.id: m};
          final seriesMapUp = {for (var s in _series) s.id: s};
          final externalMapUp = {for (var e in _externalItems) e.id: e};
          for (final id in orderIds) {
            final movie = movieMapUp[id];
            if (movie != null && !movie.isReleased) {
              _upcoming.add(movie);
              continue;
            }
            final series = seriesMapUp[id];
            if (series != null && !series.isReleased) {
              _upcoming.add(series);
              continue;
            }
            final external = externalMapUp[id];
            if (external != null) {
              _upcoming.add(external);
            }
          }
        } else {
          _upcoming.addAll(_movies.where((item) => !item.isReleased));
          _upcoming.addAll(_series.where((item) => !item.isReleased));
          _upcoming.addAll(_externalItems);
          _upcoming.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
        }

        _status = Status.fetched;
        onSuccess();
      }, (error) {
        print("Error fetching section homepage: $error");
      }, () {},
          headers: {
            'Child-Safe': isChildSafe.toString(),
          },
          maxRetries: 100);
    } catch (error) {
      print("Error: $error");
      _status = Status.failed;
    }
  }

  String getSupportPhoneNumber() {
    return _supportPhoneNumber;
  }

  String getReferralText(String code) {
    return _referralText.replaceAll('{code}', code);
  }

  String? getReferralVideoUrl() {
    return _referralVideoUrl;
  }

  String? getReferralPosterUrl() {
    return _referralPosterUrl;
  }

  String getAlertTitle() {
    return _alertTitle;
  }

  String getAlertMessage() {
    return _alertMessage;
  }

  String getGrievanceEmail() {
    return _grievanceEmail;
  }

  String getSupportEmail() {
    return _supportEmail;
  }

  String getSupportTiming() {
    return _supportTiming;
  }

  String getGrievanceName() {
    return _grievanceName;
  }

  List<Section> getSections() {
    return _sections;
  }

  List<BaseItem> getUpcoming() {
    return _upcoming;
  }

  String getShareText() {
    return _shareText;
  }

  String getShareUrl() {
    return _shareUrl;
  }

  List<ReelItem> getReels() {
    return _reels;
  }

  void clearReels() {
    _reels.clear();
  }

  void addReels(List<ReelItem> reelItems) {
    _reels.addAll(reelItems);
  }

  Status? getStatus() {
    return _status;
  }

  List<BaseItem> getMovies() {
    return _movies;
  }

  List<BaseItem> getPosters() {
    return _posters;
  }

  List<BaseItem> getSuggestionMovies(List<String> suggestions) {
    var movies = getMovies();
    return movies.where((item) => suggestions.contains(item.id)).toList();
  }

  List<BaseItem> getSeries({bool childSafe = false}) {
    if (childSafe){
      return _series.where((element) => !element.getIsAdult()).toList();
    }
    return _series;
  }

  Future<void> getVideoUrls(String baseItemId, MediaType mediaType, void Function() onSuccess, bool childSafe, {String parentId = ""}) async {
    int baseItemIndex = -1;
    BaseItem? baseItem;

    if (mediaType == MediaType.movie) {
      baseItemIndex = _movies.indexWhere((element) => element.id == baseItemId);
      if (baseItemIndex != -1) {
        baseItem = _movies[baseItemIndex];
      }
    } else if (mediaType == MediaType.series) {
      baseItemIndex = _series.indexWhere((element) => element.id == baseItemId);
      if (baseItemIndex != -1) {
        baseItem = _series[baseItemIndex];
      }
    } else if (mediaType == MediaType.episode && parentId.isNotEmpty) {
      final seriesIndex = _series.indexWhere((element) => element.id == parentId);
      if (seriesIndex != -1) {
        final series = _series[seriesIndex];
        final episodeIndex = series.episodes.indexWhere((episode) => episode.id == baseItemId);
        if (episodeIndex != -1) {
          baseItem = series.episodes[episodeIndex];
          baseItemIndex = episodeIndex;
        }
      }
    }

    if (baseItem != null && baseItemIndex >= 0) {
      if (baseItem.mediaType == MediaType.series) {
        if (baseItem.trailerUrl.isNotEmpty) {
          onSuccess();
          return;
        }
      }
      if (baseItem.videoUrl.isNotEmpty) {
        onSuccess();
        return;
      }
      await NetworkService().get(
        APIPath.getVideoUrl,
        headers: {
          "Content-Id": baseItemId,
          "Video-Content-Type": mediaType.toString().split(".")[1],
          "Series-Id": parentId,
          "Child-Safe": childSafe.toString(),
        },
        (data) {
          final videoUrl = data['body']['video_url'];
          final trailerUrl = data['body']['trailer_url'];
          final downloadUrl = data['body']['download_url'];
          if (videoUrl != null) {
            if (mediaType == MediaType.movie) {
              _movies[baseItemIndex].videoUrl = videoUrl;
              _movies[baseItemIndex].trailerUrl = trailerUrl;
              _movies[baseItemIndex].downloadUrl = downloadUrl;
            } else if (mediaType == MediaType.series) {
              _series[baseItemIndex].trailerUrl = trailerUrl;
            } else if (mediaType == MediaType.episode && parentId.isNotEmpty) {
              final seriesIndex = _series.indexWhere((element) => element.id == parentId);
              if (seriesIndex != -1) {
                final series = _series[seriesIndex];
                final episodeIndex = series.episodes.indexWhere((episode) => episode.id == baseItemId);
                if (episodeIndex != -1) {
                  _series[seriesIndex].episodes[episodeIndex].videoUrl = videoUrl;
                  _series[seriesIndex].episodes[episodeIndex].trailerUrl = trailerUrl;
                  _series[seriesIndex].episodes[episodeIndex].downloadUrl = downloadUrl;
                }
              }
            }
            onSuccess();
          }
        },
        (error) {},
        () {},
      );
    }
  }

  BaseItem? getMediaById(String id, MediaType? mediaType) {
    if (mediaType == MediaType.movie || mediaType == null) {
      final movie = _movies.firstWhereOrNull((element) => element.id == id);
      if (movie != null) return movie;
    }

    if (mediaType == MediaType.series || mediaType == null) {
      final series = _series.firstWhereOrNull((element) => element.id == id);
      if (series != null) return series;
    }

    if (mediaType == MediaType.episode || mediaType == null) {
      for (final series in _series) {
        final episode = series.episodes.firstWhereOrNull((e) => e.id == id);
        if (episode != null) return episode;
      }
    }

    if (mediaType == MediaType.external || mediaType == null) {
      final external = _externalItems.firstWhereOrNull((e) => e.id == id);
      if (external != null) return external;
    }

    return null;
  }
}
