import 'media_item.dart';

class Section {
  String title;
  int priority;
  List<BaseItem> baseItems;
  List<BaseItem> allBaseItems; // All items for "view all"
  List<String> itemIds;
  List<String> allItemIds; // All item IDs for "view all"
  String type;
  bool isContinueWatching;

  Section({
    required this.title,
    required this.priority,
    required this.itemIds,
    required this.type,
    this.isContinueWatching = false,
    List<BaseItem>? baseItems,
    List<String>? allItemIds,
    List<BaseItem>? allBaseItems,
  }) : baseItems = baseItems ?? [],
       allItemIds = allItemIds ?? itemIds,
       allBaseItems = allBaseItems ?? [];

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
        title: json['title'],
        priority: json['priority'] ?? json['position'] ?? 0,
        type: json['type'],
        itemIds: (json['item_ids'] as List<dynamic>).map((item) => item.toString()).toList(),
        allItemIds: json['all_item_ids'] != null 
            ? (json['all_item_ids'] as List<dynamic>).map((item) => item.toString()).toList()
            : (json['item_ids'] as List<dynamic>).map((item) => item.toString()).toList(),
        isContinueWatching: json['is_continue_watching'] ?? false);
  }

  Section copyWith({List<BaseItem>? baseItems, List<BaseItem>? allBaseItems}) {
    return Section(
      title: title,
      priority: priority,
      itemIds: itemIds,
      allItemIds: allItemIds,
      type: type,
      baseItems: baseItems ?? this.baseItems,
      allBaseItems: allBaseItems ?? this.allBaseItems,
      isContinueWatching: isContinueWatching,
    );
  }
}
