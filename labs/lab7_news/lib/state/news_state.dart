import 'package:flutter/foundation.dart';

import '../data/news_repository.dart';
import '../models/article.dart';

class NewsState extends ChangeNotifier {
  NewsState(this._repository);

  final NewsRepository _repository;
  final _articleIds = <String>{};
  final _usedTokens = <String>{};

  List<Article> articles = const [];
  String? category;
  String? query;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  bool hasMoreError = false;

  String? _nextPage;
  int _requestId = 0;

  bool get hasMore => _nextPage != null;

  Future<void> selectCategory(String? value) async {
    if (category == value) return;

    category = value;
    await load();
  }

  Future<void> search(String text) async {
    final trimmed = text.trim();
    final nextQuery = trimmed.isEmpty ? null : trimmed;

    if (query == nextQuery) return;

    query = nextQuery;
    await load();
  }

  Future<void> load() => _loadPage(null);

  Future<void> loadMore() async {
    final token = _nextPage;
    if (token == null || isLoading || isLoadingMore) return;

    await _loadPage(token);
  }

  Future<void> _loadPage(String? token) async {
    final requestId = ++_requestId;
    final isFirstPage = token == null;

    if (isFirstPage) {
      articles = const [];
      _articleIds.clear();
      _usedTokens.clear();
      _nextPage = null;
    }

    isLoading = isFirstPage;
    isLoadingMore = !isFirstPage;
    hasError = false;
    hasMoreError = false;
    notifyListeners();

    try {
      final page = await _repository.fetchPage(
        page: token,
        category: category,
        query: query,
      );

      if (requestId != _requestId) return;

      articles = [
        ...articles,
        for (final article in page.articles)
          if (_articleIds.add(article.id)) article,
      ];

      if (token != null) _usedTokens.add(token);
      _nextPage = _usedTokens.contains(page.nextPage) ? null : page.nextPage;
    } catch (_) {
      if (requestId != _requestId) return;

      hasError = isFirstPage;
      hasMoreError = !isFirstPage;
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }
}
