import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class FavoritesRepository extends ChangeNotifier {
  FavoritesRepository._();

  static final instance = FavoritesRepository._();
  static const _prefix = 'favorite.';

  final _prefs = SharedPreferencesAsync();
  Future<List<Article>>? _cached;

  Future<List<Article>> get articles => _cached ??= _readAll();

  Future<List<Article>> _readAll() async {
    final values = await _prefs.getAll();
    final result = <Article>[];

    for (final entry in values.entries) {
      if (entry.key.startsWith(_prefix)) {
        final json = jsonDecode(entry.value as String) as Map<String, dynamic>;
        result.add(Article.fromJson(json));
      }
    }

    result.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return result;
  }

  Future<bool> contains(String id) => _prefs.containsKey('$_prefix$id');

  Future<void> setSaved(Article article, bool saved) async {
    final key = '$_prefix${article.id}';

    if (saved) {
      await _prefs.setString(key, jsonEncode(article.toJson()));
    } else {
      await _prefs.remove(key);
    }

    reload();
  }

  void reload() {
    _cached = null;
    notifyListeners();
  }
}
