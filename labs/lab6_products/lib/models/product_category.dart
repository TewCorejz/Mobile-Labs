class ProductCategory {
  final String id;
  final String name;

  const ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    return ProductCategory(id: id, name: json['name'] as String? ?? id);
  }
}