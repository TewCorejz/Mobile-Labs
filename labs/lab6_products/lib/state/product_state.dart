import 'package:flutter/foundation.dart';

import '../data/product_api_client.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../models/product_category.dart';

enum LoadStatus { initial, loading, success, error }

enum SortOption {
  popular('По популярности'),
  priceAsc('Сначала дешёвые'),
  priceDesc('Сначала дорогие'),
  titleAsc('По названию (А–Я)');

  const SortOption(this.label);

  final String label;
}

class ProductState extends ChangeNotifier {
  ProductState(this._repository);

  static const double minPossibleRating = 0;
  static const double maxPossibleRating = 5;

  final ProductRepository _repository;

  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  List<Product> _allProducts = const [];
  Map<int, Product> _byId = const {};
  List<Product> _visibleProducts = const [];
  List<ProductCategory> _categories = const [];
  String _query = '';
  String? _selectedCategoryId;
  double _minRating = minPossibleRating;
  double _maxRating = maxPossibleRating;
  SortOption _sort = SortOption.popular;
  Set<int> _favoriteIds = const {};

  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Product> get visibleProducts => _visibleProducts;
  List<ProductCategory> get categories => _categories;
  String get query => _query;
  String? get selectedCategoryId => _selectedCategoryId;
  double get minRating => _minRating;
  double get maxRating => _maxRating;
  bool get isRatingFiltered =>
      _minRating > minPossibleRating || _maxRating < maxPossibleRating;
  SortOption get sort => _sort;

  bool get isLoading =>
      _status == LoadStatus.loading || _status == LoadStatus.initial;
  bool get hasError => _status == LoadStatus.error;
  bool get isEmptyResult =>
      _status == LoadStatus.success && _visibleProducts.isEmpty;
  bool get hasActiveFilters =>
      _query.isNotEmpty || _selectedCategoryId != null || isRatingFiltered;

  String get sectionTitle {
    if (_query.isNotEmpty) return 'Результаты поиска';
    final categoryId = _selectedCategoryId;
    if (categoryId != null) return categoryName(categoryId);
    return _sort == SortOption.popular ? 'Популярные' : 'Все продукты';
  }

  List<Product> get favoriteProducts => List.unmodifiable(
        _allProducts.where((p) => _favoriteIds.contains(p.id)),
      );

  int get favoritesCount =>
      _allProducts.where((p) => _favoriteIds.contains(p.id)).length;

  Product? productById(int id) => _byId[id];

  Future<void> init() async {
    await loadFavorites();
    await loadProducts();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_status == LoadStatus.loading) return;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final catalog =
          await _repository.getCatalog(forceRefresh: forceRefresh);
      _allProducts = List.unmodifiable(catalog.products);
      _byId = Map.unmodifiable({for (final p in catalog.products) p.id: p});
      _categories = List.unmodifiable(catalog.categories);
      _status = LoadStatus.success;
      _updateVisible();
    } on ApiException catch (e) {
      _status = LoadStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = LoadStatus.error;
      _errorMessage = 'Что-то пошло не так. Попробуйте ещё раз';
    }
    notifyListeners();
  }

  Future<void> retry() => loadProducts(forceRefresh: true);

  void setQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _updateVisible();
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId =
        _selectedCategoryId == categoryId ? null : categoryId;
    _updateVisible();
    notifyListeners();
  }

  void setRatingRange(double min, double max) {
    if (min == _minRating && max == _maxRating) return;
    _minRating = min;
    _maxRating = max;
    _updateVisible();
    notifyListeners();
  }

  void setSort(SortOption option) {
    if (option == _sort) return;
    _sort = option;
    _updateVisible();
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _selectedCategoryId = null;
    _minRating = minPossibleRating;
    _maxRating = maxPossibleRating;
    _updateVisible();
    notifyListeners();
  }

  String categoryName(String categoryId) {
    for (final c in _categories) {
      if (c.id == categoryId) return c.name;
    }
    return categoryId;
  }

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  Future<void> loadFavorites() async {
    try {
      _favoriteIds = await _repository.getFavoriteIds();
    } catch (_) {
      _favoriteIds = const {};
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Product product) async {
    final updated = Set<int>.of(_favoriteIds);
    if (!updated.remove(product.id)) {
      updated.add(product.id);
    }
    _favoriteIds = updated;
    notifyListeners();
    await _repository.saveFavoriteIds(updated);
  }

  void _updateVisible() {
    final q = _normalize(_query);
    final result = _allProducts.where((p) {
      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      final matchesQuery = q.isEmpty || _normalize(p.title).contains(q);
      final matchesRating =
          p.rating >= _minRating && p.rating <= _maxRating;
      return matchesCategory && matchesQuery && matchesRating;
    }).toList();

    final Comparator<Product> comparator = switch (_sort) {
      SortOption.popular => (a, b) => b.rating.compareTo(a.rating),
      SortOption.priceAsc => (a, b) => a.price.compareTo(b.price),
      SortOption.priceDesc => (a, b) => b.price.compareTo(a.price),
      SortOption.titleAsc => (a, b) =>
          _normalize(a.title).compareTo(_normalize(b.title)),
    };
    result.sort(comparator);

    _visibleProducts = List.unmodifiable(result);
  }

  static String _normalize(String text) =>
      text.toLowerCase().replaceAll('ё', 'е');
}