import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _favoritesKey = 'favorite_ids';
  static const String _cartKey = 'cart';
  static const String _profileNameKey = 'profile_name';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<int>> loadFavorites() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_favoritesKey) ?? const <String>[];
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> saveFavorites(Set<int> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _favoritesKey,
      ids.map((id) => id.toString()).toList(),
    );
  }

  Future<Map<int, int>> loadCart() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cartKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      final result = <int, int>{};
      decoded.forEach((key, value) {
        final id = int.tryParse(key);
        if (id != null && value is int && value > 0) {
          result[id] = value;
        }
      });
      return result;
    } on FormatException {
      return {};
    }
  }

  Future<void> saveCart(Map<int, int> cart) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(
      cart.map((id, quantity) => MapEntry(id.toString(), quantity)),
    );
    await prefs.setString(_cartKey, encoded);
  }

  Future<String?> loadProfileName() async {
    final prefs = await _prefs;
    return prefs.getString(_profileNameKey);
  }

  Future<void> saveProfileName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_profileNameKey, name);
  }
}