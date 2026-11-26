class NewsSource {
  final String name;
  final String? url;

  const NewsSource({required this.name, this.url});

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      name: json['name'] as String? ?? 'Неизвестный источник',
      url: json['url'] as String?,
    );
  }
}
