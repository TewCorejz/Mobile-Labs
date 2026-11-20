import 'package:material_ui/material_ui.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    this.compact = false,
  });

  static const int maxQuantity = 99;

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final density = compact ? VisualDensity.compact : VisualDensity.standard;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: density,
            tooltip: quantity <= 1 ? 'Удалить' : 'Уменьшить',
            onPressed: onDecrement,
            icon: Icon(quantity <= 1 ? Icons.delete_outline : Icons.remove),
          ),
          SizedBox(
            width: compact ? 24 : 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            visualDensity: density,
            tooltip: 'Увеличить',
            onPressed: quantity >= maxQuantity ? null : onIncrement,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}