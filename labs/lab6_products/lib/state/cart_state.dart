import 'package:flutter/foundation.dart';

import '../data/product_repository.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartState extends ChangeNotifier {
  CartState(this._repository);

  final ProductRepository _repository;

  Map<int, int> _quantities = const {};

  bool get isEmpty => _quantities.isEmpty;

  int get totalCount =>
      _quantities.values.fold<int>(0, (sum, quantity) => sum + quantity);

  int quantityOf(int productId) => _quantities[productId] ?? 0;

  List<CartItem> itemsFrom(Product? Function(int id) findProduct) {
    final items = <CartItem>[];
    _quantities.forEach((id, quantity) {
      final product = findProduct(id);
      if (product != null) {
        items.add(CartItem(product: product, quantity: quantity));
      }
    });
    return items;
  }

  static double totalPrice(List<CartItem> items) =>
      items.fold<double>(0, (sum, item) => sum + item.total);

  Future<void> init() async {
    try {
      _quantities = await _repository.getCart();
    } catch (_) {
      _quantities = const {};
    }
    notifyListeners();
  }

  Future<void> add(int productId) =>
      _setQuantity(productId, quantityOf(productId) + 1);

  Future<void> decrement(int productId) =>
      _setQuantity(productId, quantityOf(productId) - 1);

  Future<void> remove(int productId) => _setQuantity(productId, 0);

  Future<void> clear() async {
    _quantities = const {};
    notifyListeners();
    await _repository.saveCart(_quantities);
  }

  Future<void> _setQuantity(int productId, int quantity) async {
    final updated = Map<int, int>.of(_quantities);
    if (quantity <= 0) {
      updated.remove(productId);
    } else {
      updated[productId] = quantity;
    }
    _quantities = updated;
    notifyListeners();
    await _repository.saveCart(updated);
  }
}