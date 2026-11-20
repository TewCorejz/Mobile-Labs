import 'package:material_ui/material_ui.dart';

import '../models/product.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.size = 72,
    this.radius = 16,
  });

  final Product product;
  final double size;
  final double radius;

  static const Map<String, Color> _lightColors = {
    'fruits': Color(0xFFFFEBEE),
    'vegetables': Color(0xFFE8F5E9),
    'dairy': Color(0xFFE3F2FD),
    'bakery': Color(0xFFFFF3E0),
    'meat': Color(0xFFFCE4EC),
    'drinks': Color(0xFFE0F7FA),
    'sweets': Color(0xFFF3E5F5),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : _lightColors[product.categoryId] ??
            theme.colorScheme.surfaceContainerHighest;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: FittedBox(
        child: Text(
          product.image,
          style: const TextStyle(fontSize: 48, height: 1.1),
        ),
      ),
    );
  }
}