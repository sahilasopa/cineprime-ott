import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/main.dart';
import 'package:cineprime/presentation/pages/media/tv_show_details_page.dart';
import 'package:cineprime/providers/content_provider.dart';

/// Handles Deeplinkly resolved params: stores them until content is ready,
/// then navigates to series or series+episode highlight.
class DeeplinkPendingHandler {
  DeeplinkPendingHandler._internal();

  static final DeeplinkPendingHandler instance = DeeplinkPendingHandler._internal();

  bool _contentReady = false;
  Map<String, dynamic>? _pendingParams;

  void setPending(Map<String, dynamic> params) {
    _pendingParams = params;
    if (_contentReady) {
      _tryProcess();
    }
  }

  void onContentReady() {
    _contentReady = true;
    _tryProcess();
  }

  void _tryProcess() {
    final params = _pendingParams;
    if (params == null) return;

    String? screen;
    String? slug;
    try {
      screen = params['screen']?.toString();
      slug = params['slug']?.toString();
    } catch (_) {
      _clearPending();
      return;
    }

    if (screen == null || slug == null || slug.isEmpty) {
      _clearPending();
      return;
    }

    if (screen != 'series' && screen != 'episode') {
      _clearPending();
      return;
    }

    final String screenVal = screen;
    final String slugVal = slug;

    final context = mainNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processWithContext(params, screenVal, slugVal);
      });
      return;
    }

    _processWithContext(params, screenVal, slugVal);
  }

  void _processWithContext(Map<String, dynamic> params, String screen, String slug) {
    final context = mainNavigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _clearPending();
      return;
    }

    final contentProvider = Provider.of<ContentProvider>(context, listen: false);

    if (screen == 'series') {
      final series = contentProvider.getMediaById(slug, MediaType.series);
      if (series != null) {
        _clearPending();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TvShowDetailsPage(series),
          ),
        );
      } else {
        _clearPending();
      }
      return;
    }

    if (screen == 'episode') {
      final episode = contentProvider.getMediaById(slug, MediaType.episode);
      if (episode == null) {
        _clearPending();
        return;
      }
      final series = contentProvider.getMediaById(episode.parentSeriesId, MediaType.series);
      if (series != null) {
        _clearPending();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TvShowDetailsPage(series, highlightEpisodeId: slug),
          ),
        );
      } else {
        _clearPending();
      }
    }
  }

  void _clearPending() {
    _pendingParams = null;
  }
}
