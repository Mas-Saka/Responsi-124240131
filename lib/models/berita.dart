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
    return Berita(
      id: json['id'] ?? 0,
      title: json['title'] ?? '-',
      image_url: json['image_url'] ?? '-',
      published_at: json['published_at'] ?? '-',
      url: json['url'] ?? '-',
      authors: json['authors'] ?? '-',
      summary: json['summary'] ?? '-',
      news_site: json['news_site'] ?? '-',
    );
  }
}
