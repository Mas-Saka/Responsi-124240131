import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../services/api_service.dart';
import '../models/berita.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<List<Berita>> bookmarkFuture;

  @override
  void initState() {
    super.initState();
    bookmarkFuture = ApiService.getBerita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Bookmark')),
      body: FutureBuilder<List<Berita>>(
        future: bookmarkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tidak dapat memuat Bookmark. Periksa koneksi internet.',
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      bookmarkFuture = ApiService.getBerita();
                    }),
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }
          final beritas = snapshot.data ?? [];
          return ListView.builder(
            itemCount: beritas.length,
            itemBuilder: (context, index) {
              final berita = beritas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${berita.id}')),
                  title: Text(
                    berita.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.movie_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
