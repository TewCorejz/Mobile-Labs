import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../state/cart_state.dart';
import '../state/product_state.dart';
import '../utils/format.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/state_views.dart';
import 'product_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onOpenCatalog});

  final VoidCallback? onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    final productState = context.watch<ProductState>();
    final cart = context.watch<CartState>();
    final items = cart.itemsFrom(productState.productById);

    final Widget body;
    if (productState.isLoading && !cart.isEmpty) {
      body = const LoadingView();
    } else if (productState.hasError && !cart.isEmpty) {
      body = ErrorView(
        message: productState.errorMessage ?? 'Не удалось загрузить каталог',
        onRetry: productState.retry,
      );
    } else if (items.isEmpty) {
      body = EmptyView(
        icon: Icons.shopping_cart_outlined,
        title: 'Корзина пуста',
        message: 'Добавьте товары на экране подробной информации',
        actionLabel: onOpenCatalog == null ? null : 'Перейти в каталог',
        onAction: onOpenCatalog,
      );
    } else {
      body = Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 84, endIndent: 8),
              itemBuilder: (context, index) =>
                  _CartItemTile(item: items[index]),
            ),
          ),
          _CartSummary(items: items),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Очистить корзину',
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cart = context.read<CartState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Все товары будут удалены из корзины.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cart.clear();
    }
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartState>();
    final product = item.product;
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => cart.remove(product.id),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              ProductImage(product: product, size: 60, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatPrice(product.price)} / ${product.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(item.total),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              QuantityStepper(
                compact: true,
                quantity: item.quantity,
                onDecrement: () => cart.decrement(product.id),
                onIncrement: () => cart.add(product.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final total = CartState.totalPrice(items);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Товаров: $count',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    'Итого: ${formatPrice(total)}',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => _checkout(context, total),
                child: const Text('Оформить заказ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout(BuildContext context, double total) async {
    final cart = context.read<CartState>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Оформить заказ?'),
        content: Text('Сумма к оплате: ${formatPrice(total)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Оформить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cart.clear();
    messenger.showSnackBar(
      const SnackBar(content: Text('Заказ оформлен! Спасибо за покупку')),
    );
  }
}