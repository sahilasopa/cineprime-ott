import 'package:intl/intl.dart';

enum MediaType {
  movie,
  series,
  episode,
  trailer,
  external,
}

class CastMember {
  final int id;
  final String name;
  final String? profilePictureUrl;
  final String about;

  CastMember({
    required this.id,
    required this.name,
    this.profilePictureUrl,
    required this.about,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      about: json['about'] ?? '',
    );
  }
}

class CastAndCrew {
  final String role;
  final List<CastMember> members;

  CastAndCrew({
    required this.role,
    required this.members,
  });

  factory CastAndCrew.fromJson(Map<String, dynamic> json) {
    return CastAndCrew(
      role: json['role'] ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((memberJson) => CastMember.fromJson(memberJson))
              .toList() ??
          [],
    );
  }
}

class BaseItem {
  final String id;
  final String title;
  final String description;
  final MediaType mediaType;
  final bool isPremium;
  final bool isDownloadable;
  final String verticalPosterUrl;
  final String horizontalPosterUrl;
  final String featuredPosterUrl;
  final String squarePosterUrl;
  String videoUrl = "";
  String downloadUrl = "";
  String trailerUrl = "";
  final String length;
  final int lengthSeconds;
  final List<String> categories;
  final List<String> suggestions;
  final List<BaseItem> episodes;
  final bool isReleased;
  final bool showReleaseTime;
  final DateTime releaseTime;
  final String parentSeriesId;
  final int numberOfSeasons;
  final String? ageRating;
  final String? ageLimit;
  final List<String>? classifications;
  final int seasonNumber;
  final int episodeNumber;
  final double? titleStart;
  final double? titleEnd;
  int? lastTimestamp;
  final bool autoPlayTrailer;
  final bool showWarning;
  final List<CastAndCrew>? castAndCrew;
  final String? externalUrl;
  final int? priority;

  BaseItem({
    required this.id,
    required this.categories,
    required this.length,
    required this.suggestions,
    required this.title,
    required this.description,
    required this.verticalPosterUrl,
    required this.featuredPosterUrl,
    required this.trailerUrl,
    required this.mediaType,
    required this.episodeNumber,
    required this.releaseTime,
    required this.isPremium,
    required this.isReleased,
    required this.isDownloadable,
    required this.parentSeriesId,
    required this.seasonNumber,
    required this.numberOfSeasons,
    required this.horizontalPosterUrl,
    required this.episodes,
    this.classifications,
    this.ageLimit,
    this.lastTimestamp,
    this.ageRating,
    required this.lengthSeconds,
    this.titleStart,
    this.titleEnd,
    required this.showReleaseTime,
    required this.autoPlayTrailer,
    required this.showWarning,
    required this.squarePosterUrl,
    this.castAndCrew,
    this.externalUrl,
    this.priority,
  });

  factory BaseItem.fromJson(Map<String, dynamic> json) {
    return BaseItem(
      id: (json['id']?.toString()) ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => category.toString())
              .toList() ??
          [],
      length: json['length'] ?? '',
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((suggestion) => suggestion.toString())
              .toList() ??
          [],
      title: json['title'] ?? '',
      featuredPosterUrl: json['featured_poster_url'] ?? '',
      description: json['description'] ?? '',
      verticalPosterUrl: json['vertical_poster_url'] ?? '',
      squarePosterUrl: json['square_poster_url'] ?? '',
      trailerUrl: json['trailer_url'] ?? '',
      isDownloadable: json['is_downloadable'] ?? true,
      mediaType: _mediaTypeFromJson(json['media_type']),
      isPremium: json['is_premium'] ?? false,
      parentSeriesId: json['parent_series'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      releaseTime: json['release_time'] != null
          ? DateTime.parse(json['release_time'])
          : DateTime.now(),
      horizontalPosterUrl: json['horizontal_poster_url'] ?? '',
      isReleased: json['is_released'] ?? false,
      showReleaseTime: json['show_release_time'] ?? false,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((episodeJson) => BaseItem.fromJson(episodeJson))
              .toList() ??
          [],
      ageLimit: json['age_limit'],
      ageRating: json['age_rating'],
      lengthSeconds: json['length_seconds'] ?? 0,
      titleStart: double.tryParse(json['start_time'] ?? ""),
      titleEnd: double.tryParse(json['end_time'] ?? ""),
      classifications: (json['classifications'] as List<dynamic>?)
              ?.map((classification) => classification.toString())
              .toList() ??
          [],
      autoPlayTrailer: json['video_featured'] ?? false,
      showWarning: json['show_warning_on_adult'] ?? false,
      castAndCrew: (json['cast_and_crew'] as List<dynamic>?)
              ?.map((castCrewJson) => CastAndCrew.fromJson(castCrewJson))
              .toList() ??
          null,
      externalUrl: json['external_url']?.toString(),
      priority:
          json['priority'] is num ? (json['priority'] as num).toInt() : null,
    );
  }

  static MediaType _mediaTypeFromJson(dynamic value) {
    if (value == null) return MediaType.movie;
    final s = value.toString().toLowerCase();
    for (final e in MediaType.values) {
      if (e.toString().toLowerCase() == 'mediatype.$s') return e;
    }
    return MediaType.movie;
  }

  String getClassificationString() {
    if (categories.isNotEmpty) {
      return categories.join(" , ");
    }
    return "";
  }

  String getReleaseDate() {
    if (!showReleaseTime) {
      return "Coming Soon";
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final releaseDate =
        DateTime(releaseTime.year, releaseTime.month, releaseTime.day);

    if (releaseDate == today) {
      return "Releasing Today";
    } else if (releaseDate.isBefore(today)) {
      return "Released";
    } else {
      return "Releasing on ${DateFormat('d MMMM').format(releaseTime)}";
    }
  }

  String getFeaturedPosterUrl() {
    if (featuredPosterUrl.isNotEmpty) {
      return featuredPosterUrl;
    }
    return squarePosterUrl;
  }

  String getTitleHeaderString() {
    String header = "";
    if (ageRating != null) {
      header += ageRating!;
    }
    if (ageRating != null && ageLimit != null) {
      header += " ";
      header += ageLimit!;
    } else if (ageLimit != null) {
      header += ageLimit!;
      header += "+";
    }

    if ((ageLimit != null || ageRating != null) &&
        getClassificationString() != "") {
      header += " | ";
      header += getClassificationString();
    }
    return header;
  }

  double getPercentageWatched() {
    if (lastTimestamp == null) {
      return 0;
    }
    return (lastTimestamp! / lengthSeconds);
  }

  bool getIsAdult() {
    return (ageLimit == "18" || ageRating == "A") || showWarning;
  }
}
