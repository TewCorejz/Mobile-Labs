import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/product_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_search_field.dart';
import '../widgets/product_tile.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/state_views.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
        actions: const [SortButton(), SizedBox(width: 8)],
      ),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: ProductSearchField(),
          ),
          CategoryChips(),
          Expanded(child: _ProductListBody()),
        ],
      ),
    );
  }
}

class _ProductListBody extends StatelessWidget {
  const _ProductListBody();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductState>();

    if (state.isLoading) {
      return const LoadingView(message: 'Загружаем каталог…');
    }

    if (state.hasError) {
      return ErrorView(
        message: state.errorMessage ?? 'Не удалось загрузить каталог',
        onRetry: state.retry,
      );
    }

    if (state.isEmptyResult) {
      return EmptyView(
        icon: Icons.search_off,
        title: 'Ничего не найдено',
        message: state.hasActiveFilters
            ? 'Попробуйте изменить запрос или выбрать другую категорию'
            : 'Каталог пока пуст',
        actionLabel: state.hasActiveFilters ? 'Сбросить фильтры' : null,
        onAction: state.hasActiveFilters ? state.resetFilters : null,
      );
    }

    final products = state.visibleProducts;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.sectionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _productsCount(products.length),
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 96, endIndent: 8),
            itemBuilder: (context, index) =>
                ProductTile(product: products[index]),
          ),
        ),
      ],
    );
  }

  static String _productsCount(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    final String word;
    if (mod10 == 1 && mod100 != 11) {
      word = 'товар';
    } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      word = 'товара';
    } else {
      word = 'товаров';
    }
    return '$count $word';
  }
}