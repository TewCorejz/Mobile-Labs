class Product {
  final int id;
  final String title;
  final String categoryId;
  final double price;
  final String unit;
  final double rating;
  final String image;
  final String description;

  const Product({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.price,
    required this.unit,
    required this.rating,
    required this.image,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      categoryId: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'шт',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String? ?? '🛒',
      description: json['description'] as String? ?? '',
    );
  }
}