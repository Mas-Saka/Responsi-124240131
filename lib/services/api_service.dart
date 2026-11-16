import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berita.dart';
import '../models/bookmark.dart';

class ApiService {
  static const String baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles';

  static Future<List<Berita>> getBerita({
    String title = '',
    String image_url = '',
    String published_at = '',
    String url = '',
    String authors = '',
    String summary = '',
    String news_site = '',
  }) async {
    final query = <String, String>{};
    if (title.isNotEmpty) query['title'] = title;
    if (image_url.isNotEmpty) query['image_url'] = image_url;
    if (published_at.isNotEmpty) query['published_at'] = published_at;
    if (url.isNotEmpty) query['url'] = url;
    if (authors.isNotEmpty) query['authors'] = authors;
    if (summary.isNotEmpty) query['summary'] = summary;
    if (news_site.isNotEmpty) query['news_site'] = news_site;

    final uri = Uri.parse(
      '$baseUrl/berita',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((item) => Berita.fromJson(item)).toList();
    }
    if (response.statusCode == 404) return [];
    throw Exception('Gagal mengambil data berita (${response.statusCode})');
  }

  static Future<Berita> getBeritaDetail(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/berita/$id'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return Berita.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal mengambil detail berita');
  }
}
