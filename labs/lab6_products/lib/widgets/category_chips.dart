import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/product_category.dart';
import '../state/product_state.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.select<ProductState, List<ProductCategory>>(
      (s) => s.categories,
    );
    final selectedId = context.select<ProductState, String?>(
      (s) => s.selectedCategoryId,
    );
    final scheme = Theme.of(context).colorScheme;

    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          final selected = category == null
              ? selectedId == null
              : category.id == selectedId;

          return Center(
            child: ChoiceChip(
              label: Text(category?.name ?? 'Все'),
              selected: selected,
              showCheckmark: false,
              selectedColor: scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              labelStyle: TextStyle(
                color: selected ? scheme.onPrimary : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) =>
                  context.read<ProductState>().selectCategory(category?.id),
            ),
          );
        },
      ),
    );
  }
}