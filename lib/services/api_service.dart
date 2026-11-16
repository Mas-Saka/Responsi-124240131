import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/berita.dart';

class ApiService {
  static const String baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/';

  static Future<List<Berita>> getBerita({String news_site = ''}) async {
    final query = <String, String>{'limit': '10', 'ordering': '-published_at'};

    if (news_site.trim().isNotEmpty) {
      query['news_site'] = news_site.trim();
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (data is! Map || data['results'] is! List) {
        throw Exception('Format data dari API tidak sesuai.');
      }

      final List results = data['results'];
      return results
          .whereType<Map<String, dynamic>>()
          .map((item) => Berita.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil berita: $e');
    }
  }

  static Future<Berita> getBeritaDetail(int id) async {
    final uri = Uri.parse('$baseUrl$id/');

    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return Berita.fromJson(data);
      }
      throw Exception('Format detail berita tidak sesuai.');
    }

    throw Exception(
      'Gagal mengambil detail berita: HTTP ${response.statusCode}',
    );
  }
}
