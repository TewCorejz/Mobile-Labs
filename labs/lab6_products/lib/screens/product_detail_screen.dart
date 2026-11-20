import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart_state.dart';
import '../state/product_state.dart';
import '../utils/format.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/rating_label.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<ProductState, bool>(
      (s) => s.isFavorite(product.id),
    );
    final categoryName = context.select<ProductState, String>(
      (s) => s.categoryName(product.categoryId),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
            onPressed: () =>
                context.read<ProductState>().toggleFavorite(product),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: ProductImage(product: product, size: 200, radius: 32),
          ),
          const SizedBox(height: 24),
          Text(
            product.title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              RatingLabel(rating: product.rating, large: true),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${formatPrice(product.price)} / ${product.unit}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Описание',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            product.description.isEmpty
                ? 'Описание отсутствует'
                : product.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _InfoRow(label: 'Категория', value: categoryName),
          _InfoRow(label: 'Единица измерения', value: product.unit),
          _InfoRow(label: 'Рейтинг', value: '${formatRating(product.rating)} из 5'),
          _InfoRow(label: 'Артикул', value: '№ ${product.id}'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _CartBar(product: product),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final quantity = context.select<CartState, int>(
      (c) => c.quantityOf(product.id),
    );
    final cart = context.read<CartState>();

    if (quantity == 0) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: () {
          cart.add(product.id);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('«${product.title}» добавлен в корзину'),
                duration: const Duration(seconds: 2),
              ),
            );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: Text('В корзину · ${formatPrice(product.price)}'),
      );
    }

    return Row(
      children: [
        QuantityStepper(
          quantity: quantity,
          onDecrement: () => cart.decrement(product.id),
          onIncrement: () => cart.add(product.id),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'В корзине',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                formatPrice(product.price * quantity),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}