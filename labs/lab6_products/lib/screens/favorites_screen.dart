import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/product_state.dart';
import '../widgets/product_tile.dart';
import '../widgets/state_views.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onOpenCatalog});

  final VoidCallback? onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductState>();
    final favorites = state.favoriteProducts;

    final Widget body;
    if (state.isLoading && favorites.isEmpty) {
      body = const LoadingView();
    } else if (state.hasError && favorites.isEmpty) {
      body = ErrorView(
        message: state.errorMessage ?? 'Не удалось загрузить каталог',
        onRetry: state.retry,
      );
    } else if (favorites.isEmpty) {
      body = EmptyView(
        icon: Icons.favorite_border,
        title: 'Здесь пока пусто',
        message: 'Нажмите ♡ у товара, чтобы добавить его в избранное',
        actionLabel: onOpenCatalog == null ? null : 'Перейти в каталог',
        onAction: onOpenCatalog,
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        itemCount: favorites.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 96, endIndent: 8),
        itemBuilder: (context, index) =>
            ProductTile(product: favorites[index]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: body,
    );
  }
}