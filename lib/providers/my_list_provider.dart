import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyListProvider extends ChangeNotifier {
  static const _key = 'butterfly_my_list_ids';
  final List<String> _ids = [];
  bool _ready = false;

  bool get isReady => _ready;
  List<String> get ids => List.unmodifiable(_ids);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_key) ?? []);
    _ready = true;
    notifyListeners();
  }

  bool contains(String id) => _ids.contains(id);

  Future<bool> toggle(String id) async {
    final added = !_ids.contains(id);
    if (added) {
      _ids.insert(0, id);
    } else {
      _ids.remove(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids);
    notifyListeners();
    return added;
  }
}
