import 'package:flutter/material.dart';
import 'package:flutter_deeplinkly/flutter_deeplinkly.dart';
import 'package:flutter_deeplinkly/models/deeplinkly.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';

class DeepLinklyLinkService {
  DeepLinklyLinkService._internal();

  static final DeepLinklyLinkService instance = DeepLinklyLinkService._internal();

  Future<String> generateLink(
    BuildContext context, {
    required LinkType type,
    required Map<String, dynamic> data,
  }) async {
    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = auth.getUser();
    final Map<String, dynamic> metadata = {'screen': type.name, ...data};
    if (user != null) metadata['user_id'] = user.id;

    late final DeeplinklyContent content;

    switch (type) {
      case LinkType.episode:
        final episodeId = data['slug'] ?? '';
        content = DeeplinklyContent(
          canonicalIdentifier: 'episodes/$episodeId',
          title: data['title'],
          description: data['description'],
          metadata: metadata,
          imageUrl: data['poster']
        );
        break;

      case LinkType.series:
        final seriesId = data['slug'] ?? '';
        final title = data['title'] ?? 'Series';
        final description = data['description'] ?? '';
        content = DeeplinklyContent(
          canonicalIdentifier: 'series/$seriesId',
          title: title,
          description: description,
          imageUrl: data['poster'],
          metadata: metadata,
        );
        break;

      case LinkType.films:
        final filmId = data['slug'] ?? '';
        content = DeeplinklyContent(
          canonicalIdentifier: 'films/$filmId',
          title: data['title'] ?? 'Films',
          description: data['description'] ?? '',
          imageUrl: data['poster'] ?? '',
          metadata: metadata,
        );
        break;
    }

    final result = await FlutterDeeplinkly.generateLink(
      content: content,
      options: const DeeplinklyLinkOptions(channel: 'app', feature: 'share'),
    );

    return result.url ?? '';
  }
}

/// Enum to represent which type of deep link we’re generating.
enum LinkType { episode, series, films }
