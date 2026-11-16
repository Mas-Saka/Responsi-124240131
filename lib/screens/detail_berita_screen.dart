import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/berita.dart';

class DetailScreen extends StatefulWidget {
  final Berita berita;
  final bool isFavorite;
  final Future<void> Function(Berita) onFavoriteChanged;

  const DetailScreen({
    super.key,
    required this.berita,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool favorite;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
  }

  Future<void> toggleFavorite() async {
    if (isSaving) return;
    setState(() => isSaving = true);

    try {
      await widget.onFavoriteChanged(widget.berita);
      if (!mounted) return;
      setState(() => favorite = !favorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favorite
                ? 'Berita berhasil ditambahkan ke bookmark'
                : 'Berita dihapus dari bookmark',
          ),
          backgroundColor: favorite ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> openArticle() async {
    final uri = Uri.tryParse(widget.berita.url);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat artikel tidak valid.')),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka artikel.')),
      );
    }
  }

  String formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value.isEmpty ? '-' : value;
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final berita = widget.berita;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Berita')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              berita.image_url,
              height: 230,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 230,
                color: Colors.black12,
                child: const Icon(Icons.rocket_launch, size: 64),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            berita.title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                detailRow('Sumber Berita', berita.news_site),
                detailRow('Tanggal Publikasi', formatDate(berita.published_at)),
                detailRow('Penulis', berita.authors),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ringkasan Berita',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            berita.summary,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: openArticle,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Read Full Article'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isSaving ? null : toggleFavorite,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    favorite ? Icons.bookmark : Icons.bookmark_border,
                    color: favorite ? Colors.orange : null,
                  ),
            label: Text(
              favorite ? 'Hapus dari Bookmark' : 'Tambah ke Bookmark',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      subtitle: Text(
        value.isEmpty ? '-' : value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
