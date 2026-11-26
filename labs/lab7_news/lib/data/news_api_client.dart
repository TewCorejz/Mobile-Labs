import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

typedef NewsPage = ({List<Article> articles, String? nextPage});

class NewsApiClient {
  final String apiKey;

  const NewsApiClient(this.apiKey);

  Future<NewsPage> fetchPage({
    String? page,
    String? category,
    String? query,
  }) async {
    final uri = Uri.https('newsdata.io', '/api/2/news', {
      'apikey': apiKey,
      'language': 'ru',
      'size': '10',
      'page': ?page,
      'category': ?category,
      'q': ?query,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Не удалось загрузить новости (HTTP ${response.statusCode})',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (data['status'] != 'success') {
      throw Exception('Новостной сервис вернул ошибку');
    }

    final results = data['results'] as List<dynamic>;

    return (
      articles: results
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextPage: data['next_page'] as String?,
    );
  }
}
