import 'package:flutter/foundation.dart';

import '../../data/models/city.dart';
import '../../data/repository/favorites_repository.dart';

class FavoritesNotifier extends ChangeNotifier {
  FavoritesNotifier(this._repository) : _cities = _repository.load();

  final FavoritesRepository _repository;
  final List<City> _cities;

  List<City> get cities => List.unmodifiable(_cities);

  bool contains(City city) => _cities.contains(city);

  Future<void> toggle(City city) =>
      contains(city) ? remove(city) : _update(() => _cities.add(city));

  Future<void> remove(City city) => _update(() => _cities.remove(city));

  Future<void> _update(VoidCallback change) {
    change();
    notifyListeners();
    return _repository.save(_cities);
  }
}