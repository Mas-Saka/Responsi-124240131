class Berita {
  final int id;
  final String title;
  final String image_url;
  final String published_at;
  final String url;
  final String authors;
  final String summary;
  final String news_site;

  Berita({
    required this.id,
    required this.title,
    required this.image_url,
    required this.published_at,
    required this.url,
    required this.authors,
    required this.summary,
    required this.news_site,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    String authorName = '-';
    final authorsData = json['authors'];

    if (authorsData is String && authorsData.isNotEmpty) {
      authorName = authorsData;
    } else if (authorsData is List && authorsData.isNotEmpty) {
      authorName = authorsData
          .map((author) {
            if (author is Map) {
              return author['name']?.toString() ?? '';
            }
            return '';
          })
          .where((name) => name.isNotEmpty)
          .join(', ');

      if (authorName.isEmpty) authorName = '-';
    }

    return Berita(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '-',
      image_url: json['image_url']?.toString() ?? '',
      published_at: json['published_at']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      authors: authorName,
      summary: json['summary']?.toString() ?? '-',
      news_site: json['news_site']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': image_url,
      'published_at': published_at,
      'url': url,
      'authors': authors,
      'summary': summary,
      'news_site': news_site,
    };
  }
}
