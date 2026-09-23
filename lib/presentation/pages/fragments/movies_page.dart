import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/controls/text_input.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _showsPageState();
}

class _showsPageState extends State<MoviesPage> {
  final List<BaseItem> _shows = [];
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    if (_shows.isEmpty && searchController.text.toString().isEmpty) {
      _shows.addAll(contentProvider.getMovies());
      _shows.addAll(contentProvider.getSeries());
    }
    searchController.addListener(() {
      _shows.clear();
      if (searchController.text.toString().isEmpty) {
        setState(() {
          _shows.addAll(contentProvider.getMovies());
          _shows.addAll(contentProvider.getSeries());
        });
      } else {
        setState(() {
          _shows.addAll((contentProvider.getMovies().where((movie) => movie.title.toLowerCase().contains(searchController.text.toLowerCase()))));
          _shows.addAll((contentProvider.getSeries().where((series) => series.title.toLowerCase().contains(searchController.text.toLowerCase()))));
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Movies", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextInput(
                controller: searchController,
                hintText: "Search",
                obscureText: false,
                isLast: true,
              ),
              if (contentProvider.getStatus() == Status.fetching)
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
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
                  padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: _shows.length,
                    itemBuilder: (context, index) {
                      return MediaItem(baseItem: _shows[index]);
                    },
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: EmptyState(
                    icon: Icons.movie_filter_outlined,
                    title: "We don't have this yet",
                    subtitle: 'Try a different title or check back later.',
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
