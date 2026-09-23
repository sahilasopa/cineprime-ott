enum ReelMediaType {
  movie,
  series,
  episode,
}

class ReelItem {
  final String id;
  final String title;
  final bool isLiked;
  final String? mediaId;
  final ReelMediaType mediaType;
  String videoUrl = "";
  String shareText = "";
  String shareSubject = "";

  ReelItem({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.isLiked,
    required this.mediaId,
    required this.videoUrl,
    required this.shareText,
    required this.shareSubject,
  });

  factory ReelItem.fromJson(Map<String, dynamic> json) {
    return ReelItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      mediaType: ReelMediaType.values.firstWhere(
          (element) => element.toString() == "MediaType.${json['media_type']}",
          orElse: () => ReelMediaType.movie),
      isLiked: json['is_liked'],
      mediaId: json['baseitem_id'],
      videoUrl: json['video_url'],
      shareText: json['share_text'],
      shareSubject: json['share_subject'],
    );
  }
}
