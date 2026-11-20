import 'package:material_ui/material_ui.dart';

import '../utils/format.dart';

class RatingLabel extends StatelessWidget {
  const RatingLabel({super.key, required this.rating, this.large = false});

  final double rating;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: large ? 22 : 18,
          color: const Color(0xFFFFB300),
        ),
        const SizedBox(width: 2),
        Text(
          formatRating(rating),
          style: (large ? textTheme.titleMedium : textTheme.bodyMedium)
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}