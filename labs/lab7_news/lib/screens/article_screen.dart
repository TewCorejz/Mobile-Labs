import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../widgets/article_image.dart';

import '../widgets/favorite_button.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({
    super.key,
    required this.article,
    required this.subtitle,
  });

  final Article article;
  final String subtitle;

  Future<bool> _openSource() async {
    final uri = Uri.tryParse(article.url.trim());

    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = article.description?.trim() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новость'),
        actions: [FavoriteButton(key: ValueKey(article.id), article: article)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ArticleImage(url: article.imageUrl),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.blueGrey)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.45),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Читать оригинал'),
            onPressed: () async {
              final opened = await _openSource();

              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Не удалось открыть ссылку')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
