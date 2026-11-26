import 'news_source.dart';

class Article {
  final String id;
  final String title;
  final String url;
  final String? description;
  final String? imageUrl;
  final DateTime publishedAt;
  final NewsSource source;

  const Article({
    required this.id,
    required this.title,
    required this.url,
    required this.publishedAt,
    required this.source,
    this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'meta_description': description,
    'published_at': publishedAt.toUtc().toIso8601String(),
    'media': {'image_url': imageUrl},
    'source': {'name': source.name, 'url': source.url},
  };

  factory Article.fromJson(Map<String, dynamic> json) {
    final media = json['media'] as Map<String, dynamic>?;
    final source = json['source'] as Map<String, dynamic>?;

    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      description: json['meta_description'] as String?,
      imageUrl: media?['image_url'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
      source: NewsSource.fromJson(source ?? const {}),
    );
  }
}
