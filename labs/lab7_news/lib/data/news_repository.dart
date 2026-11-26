import 'news_api_client.dart';

class NewsRepository {
  const NewsRepository(this._client);

  final NewsApiClient _client;

  Future<NewsPage> fetchPage({String? page, String? category, String? query}) {
    return _client.fetchPage(page: page, category: category, query: query);
  }
}
