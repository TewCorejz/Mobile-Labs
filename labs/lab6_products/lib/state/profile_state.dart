import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';

class ProfileState extends ChangeNotifier {
  ProfileState(this._repository);

  static const String defaultName = 'Студент';

  final ProductRepository _repository;

  String _name = defaultName;

  String get name => _name;

  String get initials {
    final letters = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  Future<void> init() async {
    try {
      final saved = await _repository.getProfileName();
      if (saved != null && saved.trim().isNotEmpty) {
        _name = saved;
      }
    } catch (_) {
      _name = defaultName;
    }
    notifyListeners();
  }

  Future<void> updateName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == _name) return;
    _name = trimmed;
    notifyListeners();
    await _repository.saveProfileName(trimmed);
  }
}