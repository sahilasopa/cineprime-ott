import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/models/media/section.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchPage extends StatefulWidget {
  final Section? section;

  const SearchPage({super.key, this.section});

  @override
  State<SearchPage> createState() => _ShowsPageState();
}

class _ShowsPageState extends State<SearchPage> {
  final List<BaseItem> _shows = [];
  final searchController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void dispose() {
    _speech.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _stoppedListening() {
    if (mounted && _isListening) setState(() => _isListening = false);
  }

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      _stoppedListening();
      return;
    }

    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == SpeechToText.doneStatus || status == SpeechToText.notListeningStatus) {
            _stoppedListening();
          }
        },
        onError: (_) => _stoppedListening(),
      );
    }

    if (!mounted) return;
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice search is not available on this device.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        searchController.value = TextEditingValue(
          text: result.recognizedWords,
          selection: TextSelection.collapsed(offset: result.recognizedWords.length),
        );
      },
      listenOptions: SpeechListenOptions(listenMode: ListenMode.search),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    if (_shows.isEmpty && searchController.text.toString().isEmpty) {
      if (widget.section != null) {
        // Use allBaseItems for "view all" page to show all items from the section
        _shows.addAll(widget.section!.allBaseItems.where((item) => item.isReleased));
      } else {
        _shows.addAll(contentProvider.getSeries().where((item) => item.isReleased));
        _shows.addAll(contentProvider.getMovies().where((item) => item.isReleased));
      }
    }
    searchController.addListener(() {
      _shows.clear();
      if (searchController.text.toString().isEmpty) {
        setState(() {
          _shows.addAll(contentProvider.getMovies().where((item) => item.isReleased));
          _shows.addAll(contentProvider.getSeries().where((item) => item.isReleased));
        });
      } else {
        setState(() {
          _shows.addAll((contentProvider.getMovies().where((movie) => movie.isReleased && movie.title.toLowerCase().contains(searchController.text.toLowerCase()))));
          _shows.addAll((contentProvider.getSeries().where((series) => series.isReleased && series.title.toLowerCase().contains(searchController.text.toLowerCase()))));
        });
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.section != null
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  widget.section!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Explore'),
              ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (widget.section == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.colorInputFill,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.colorInputBorder),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppColors.colorPrimary,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search for movies, series, actors...',
                          hintStyle: const TextStyle(color: AppColors.colorHint),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.colorHint),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          suffixIcon: PlatformUtils.isWeb
                              ? null
                              : IconButton(
                                  onPressed: _toggleVoiceSearch,
                                  icon: Icon(
                                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                    color: _isListening ? AppColors.colorPrimary : AppColors.colorHint,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                if (widget.section == null)
                  const SizedBox(height: 10),
                if (contentProvider.getStatus() == Status.fetching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return const ShimmerMediaItem();
                      },
                    ),
                  )
                else if (_shows.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 8,
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2 / 3,
                          ),
                          itemCount: _shows.length,
                          itemBuilder: (context, index) {
                            return MediaItem(baseItem: _shows[index]);
                          },
                        );
                      },
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: "We don't have this yet",
                      subtitle: 'Try a different title, topic, or keyword.',
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
