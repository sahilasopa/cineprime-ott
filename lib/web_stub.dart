class LocalStorage {
  String? _value;

  String? getItem(String key) => _value;
  void setItem(String key, String value) => _value = value;
  void removeItem(String key) => _value = null;
}

class FakeWindow {
  final LocalStorage localStorage = LocalStorage();
}

final FakeWindow window = FakeWindow();
