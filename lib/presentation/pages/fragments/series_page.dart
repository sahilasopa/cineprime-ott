import 'package:flutter/material.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:cineprime/presentation/components/controls/text_input.dart';
import 'package:cineprime/presentation/components/media/media_item.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:provider/provider.dart';

import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final List<BaseItem> _series = [];
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    if (_series.isEmpty && searchController.text.toString().isEmpty) {
      _series.addAll(contentProvider.getSeries());
    }
    searchController.addListener(() {
      _series.clear();
      if (searchController.text.toString().isEmpty) {
        setState(() {
          _series.addAll(contentProvider.getSeries());
        });
      } else {
        setState(() {
          _series.addAll((contentProvider.getSeries().where((series) => series.title.toLowerCase().contains(searchController.text.toLowerCase()))));
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Web Series", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
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
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return const ShimmerMediaItem();
                    },
                  ),
                )
              else if (_series.isNotEmpty)
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
                    itemCount: _series.length,
                    itemBuilder: (context, index) {
                      return MediaItem(baseItem: _series[index]);
                    },
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: EmptyState(
                    icon: Icons.tv_outlined,
                    title: 'No TV shows found',
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
