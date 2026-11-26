import '../widgets/article_tile.dart';
import '../widgets/featured_article_card.dart';

import 'package:material_ui/material_ui.dart';

import '../state/news_state.dart';

import '../widgets/news_search_title.dart';

import 'article_screen.dart';

const _categories = <String, String?>{
  'Все': null,
  'Технологии': 'technology',
  'Бизнес': 'business',
  'Спорт': 'sports',
};

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key, required this.state});

  final NewsState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: NewsSearchTitle(onSearch: state.search),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ListenableBuilder(
              listenable: state,
              builder: (context, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final entry in _categories.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(entry.key),
                            selected: state.category == entry.value,
                            onSelected: (_) =>
                                state.selectCategory(entry.value),
                            showCheckmark: false,
                            selectedColor: const Color(0xFF006AFF),
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            labelStyle: TextStyle(
                              color: state.category == entry.value
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: state.load,
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError) {
              return Center(
                child: FilledButton(
                  onPressed: state.load,
                  child: const Text('Не удалось загрузить. Повторить'),
                ),
              );
            }

            if (state.articles.isEmpty && !state.hasMore) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        state.query == null
                            ? 'Новостей пока нет'
                            : 'По запросу «${state.query}» ничего не найдено',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            return NotificationListener<ScrollEndNotification>(
              onNotification: (event) {
                final nearEnd = event.metrics.extentAfter < 250;
                final awayFromTop = event.metrics.extentBefore > 0;

                if (event.depth == 0 &&
                    awayFromTop &&
                    nearEnd &&
                    state.hasMore &&
                    !state.hasMoreError) {
                  state.loadMore();
                }

                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: state.articles.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  if (index == state.articles.length) {
                    if (state.isLoadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Center(
                      child: TextButton(
                        onPressed: state.loadMore,
                        child: Text(
                          state.hasMoreError
                              ? 'Повторить загрузку'
                              : 'Загрузить ещё',
                        ),
                      ),
                    );
                  }

                  final article = state.articles[index];
                  final date = article.publishedAt.toLocal();
                  final day = date.day.toString().padLeft(2, '0');
                  final month = date.month.toString().padLeft(2, '0');
                  final subtitle =
                      '$day.$month.${date.year}  •  ${article.source.name}';

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ArticleScreen(
                            article: article,
                            subtitle: subtitle,
                          ),
                        ),
                      );
                    },
                    child: index == 0
                        ? FeaturedArticleCard(
                            article: article,
                            subtitle: subtitle,
                          )
                        : ArticleTile(article: article, subtitle: subtitle),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
