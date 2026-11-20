import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/product_state.dart';

class ProductSearchField extends StatefulWidget {
  const ProductSearchField({super.key});

  @override
  State<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<ProductSearchField> {
  final TextEditingController _controller = TextEditingController();
  late final ProductState _state;

  @override
  void initState() {
    super.initState();
    _state = context.read<ProductState>();
    _controller.text = _state.query;
    _state.addListener(_syncWithState);
  }

  void _syncWithState() {
    if (_state.query.isEmpty && _controller.text.trim().isNotEmpty) {
      _controller.clear();
    }
  }

  void _clear() {
    _controller.clear();
    _state.setQuery('');
  }

  @override
  void dispose() {
    _state.removeListener(_syncWithState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          onChanged: _state.setQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Поиск продуктов…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Очистить',
                    icon: const Icon(Icons.close),
                    onPressed: _clear,
                  ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}