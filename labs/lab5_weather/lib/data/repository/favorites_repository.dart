import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';

class FavoritesRepository {
  const FavoritesRepository(this._preferences);

  static const _key = 'favorite_cities';

  final SharedPreferences _preferences;

  List<City> load() {
    final raw = _preferences.getString(_key);
    if (raw == null) return [];

    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(List<City> cities) {
    final raw = jsonEncode(cities.map((city) => city.toJson()).toList());
    return _preferences.setString(_key, raw);
  }
}