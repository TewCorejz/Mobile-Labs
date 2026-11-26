import 'package:material_ui/material_ui.dart';

import '../data/favorites_repository.dart';
import '../models/article.dart';
import '../widgets/article_tile.dart';
import 'article_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FavoritesRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное'), centerTitle: false),
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, _) => FutureBuilder<List<Article>>(
          future: repository.articles,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: TextButton(
                  onPressed: repository.reload,
                  child: const Text('Не удалось загрузить. Повторить'),
                ),
              );
            }

            final articles = snapshot.requireData;

            if (articles.isEmpty) {
              return const Center(
                child: Text('Здесь появятся сохранённые новости'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final article = articles[index];
                final date = MaterialLocalizations.of(context)
                    .formatCompactDate(article.publishedAt.toLocal());
                final subtitle = '$date  •  ${article.source.name}';

                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ArticleScreen(article: article, subtitle: subtitle),
                    ),
                  ),
                  child: ArticleTile(article: article, subtitle: subtitle),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
