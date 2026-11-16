class Bookmark {
  final int id;
  final String title;
  final String image_url;
  final String published_at;

  Bookmark({
    required this.id,
    required this.title,
    required this.image_url,
    required this.published_at,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? 0,
      title: json['title'] ?? '-',
      image_url: json['image_url'] ?? '-',
      published_at: json['published_at'] ?? '',
    );
  }
}
