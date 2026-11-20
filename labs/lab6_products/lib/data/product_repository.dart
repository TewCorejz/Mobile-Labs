import '../models/catalog.dart';
import 'local_storage.dart';
import 'product_api_client.dart';

class ProductRepository {
  final ProductApiClient _api;
  final LocalStorage _storage;

  Catalog? _cache;

  ProductRepository({ProductApiClient? api, LocalStorage? storage})
      : _api = api ?? ProductApiClient(),
        _storage = storage ?? LocalStorage();

  Future<Catalog> getCatalog({bool forceRefresh = false}) async {
    final cached = _cache;
    if (!forceRefresh && cached != null) return cached;
    final catalog = await _api.fetchCatalog();
    _cache = catalog;
    return catalog;
  }

  Future<Set<int>> getFavoriteIds() => _storage.loadFavorites();

  Future<void> saveFavoriteIds(Set<int> ids) => _storage.saveFavorites(ids);

  Future<Map<int, int>> getCart() => _storage.loadCart();

  Future<void> saveCart(Map<int, int> cart) => _storage.saveCart(cart);

  Future<String?> getProfileName() => _storage.loadProfileName();

  Future<void> saveProfileName(String name) =>
      _storage.saveProfileName(name);
}