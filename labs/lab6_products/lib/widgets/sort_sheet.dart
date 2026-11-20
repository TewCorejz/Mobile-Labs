import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/product_state.dart';
import '../utils/format.dart';

class SortButton extends StatelessWidget {
  const SortButton({super.key});

  @override
  Widget build(BuildContext context) {
    final sort = context.select<ProductState, SortOption>((s) => s.sort);
    final ratingFiltered =
        context.select<ProductState, bool>((s) => s.isRatingFiltered);

    return IconButton(
      tooltip: 'Сортировка и фильтры',
      onPressed: () => showSortSheet(context),
      icon: Badge(
        isLabelVisible: sort != SortOption.popular || ratingFiltered,
        child: Icon(
          Icons.filter_list,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

Future<void> showSortSheet(BuildContext context) {
  final state = context.read<ProductState>();

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final titleStyle =
          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text('Сортировка', style: titleStyle),
              ),
              for (final option in SortOption.values)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(option.label),
                  trailing: option == state.sort
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    state.setSort(option);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text('Рейтинг', style: titleStyle),
              ),
              _RatingRangeFilter(state: state),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

/// Ползунок «от – до» по оценке. Пока палец на ползунке, значения хранятся
/// локально; в ProductState они уходят, когда пользователь его отпускает.
class _RatingRangeFilter extends StatefulWidget {
  const _RatingRangeFilter({required this.state});

  final ProductState state;

  @override
  State<_RatingRangeFilter> createState() => _RatingRangeFilterState();
}

class _RatingRangeFilterState extends State<_RatingRangeFilter> {
  late RangeValues _values =
      RangeValues(widget.state.minRating, widget.state.maxRating);

  void _apply(RangeValues values) {
    widget.state.setRatingRange(values.start, values.end);
  }

  void _reset() {
    const full = RangeValues(
      ProductState.minPossibleRating,
      ProductState.maxPossibleRating,
    );
    setState(() => _values = full);
    _apply(full);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFull = _values.start == ProductState.minPossibleRating &&
        _values.end == ProductState.maxPossibleRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'от ${formatRating(_values.start)} '
                'до ${formatRating(_values.end)}',
                style: textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (!isFull)
                TextButton(onPressed: _reset, child: const Text('Сбросить')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RangeSlider(
            values: _values,
            min: ProductState.minPossibleRating,
            max: ProductState.maxPossibleRating,
            divisions: 10,
            labels: RangeLabels(
              formatRating(_values.start),
              formatRating(_values.end),
            ),
            onChanged: (values) => setState(() => _values = values),
            onChangeEnd: _apply,
          ),
        ),
      ],
    );
  }
}
