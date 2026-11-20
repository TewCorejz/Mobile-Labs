import 'product.dart';
import 'product_category.dart';

class Catalog {
  final List<ProductCategory> categories;
  final List<Product> products;

  const Catalog({required this.categories, required this.products});

  factory Catalog.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? const [])
        .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    final products = (json['products'] as List<dynamic>? ?? const [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    return Catalog(categories: categories, products: products);
  }
}