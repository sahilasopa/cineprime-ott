import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/media/media_item.dart';
import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'controls/expandable_text.dart';

class CenteredTabWidget extends StatefulWidget {
  final BaseItem baseItem;

  const CenteredTabWidget({super.key, required this.baseItem});

  @override
  _CenteredTabWidgetState createState() => _CenteredTabWidgetState();
}

class _CenteredTabWidgetState extends State<CenteredTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Description'),
              Tab(text: 'Cast & Crew'),
            ],
            indicatorColor: AppColors.colorPrimary,
            dividerColor: Colors.transparent,
            unselectedLabelColor: AppColors.colorTextMuted,
            labelColor: Colors.white,
          ),
          AutoScaleTabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpandableTextWidget(
                      text: widget.baseItem.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Center(
                  child: Text(
                'Coming Soon',
                style: TextStyle(color: Colors.white),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
