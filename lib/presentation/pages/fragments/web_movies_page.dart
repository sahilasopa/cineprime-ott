import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/controls/text_input.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';

class WebMoviesPage extends StatefulWidget {
  const WebMoviesPage({super.key});

  @override
  State<WebMoviesPage> createState() => _showsPageState();
}

class _showsPageState extends State<WebMoviesPage> {
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
    }
    searchController.addListener(() {
      _shows.clear();
      if (searchController.text.toString().isEmpty) {
        setState(() {
          _shows.addAll(contentProvider.getMovies());
        });
      } else {
        setState(() {
          _shows.addAll((contentProvider.getMovies().where((movie) => movie.title.toLowerCase().contains(searchController.text.toLowerCase()))));
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Web Movies", style: TextStyle(color: Colors.white)),
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
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: const Center(child: Text("Oops! We don't have this content at the moment", style: TextStyle(color: Colors.white70, fontSize: 18))),
                )
            ],
          ),
        ),
      ),
    );
  }
}
