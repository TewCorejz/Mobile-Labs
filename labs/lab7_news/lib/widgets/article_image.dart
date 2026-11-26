import 'package:material_ui/material_ui.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: Color(0xFFE8EDF3),
      child: Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF8592A3)),
      ),
    );

    final imageUrl = url?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return placeholder;

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
