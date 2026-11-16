import 'package:flutter/material.dart';
import '../models/berita.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final bool isFavorite;
  final Function(int) onFavoriteChanged;

  const DetailScreen({
    super.key,
    required this.id,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool favorite;
  late Future<Berita> characterFuture;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
    characterFuture = ApiService.getBeritaDetail(widget.id);
  }

  void toggleFavorite() {
    setState(() => favorite = !favorite);
    widget.onFavoriteChanged(widget.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          favorite
              ? 'Karakter ditambahkan ke favorit'
              : 'Karakter dihapus dari favorit',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Karakter')),
      body: FutureBuilder<Berita>(
        future: characterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat detail karakter.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      characterFuture = ApiService.getBeritaDetail(widget.id);
                    }),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          final berita = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  berita.image_url,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                berita.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Column(
                  children: [detailRow('news_site', berita.news_site)],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: toggleFavorite,
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  favorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: favorite
                      ? Colors.red
                      : const Color(0xFF247A58),
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ],
          );
        },
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
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
