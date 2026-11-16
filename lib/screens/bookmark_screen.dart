import 'package:flutter/material.dart';
import '../models/berita.dart';
import '../services/local_service.dart';
import '../widgets/berita_card.dart';
import 'detail_berita_screen.dart';

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
    bookmarkFuture = LocalService.getBookmarks();
  }

  Future<void> reloadBookmarks() async {
    setState(() {
      bookmarkFuture = LocalService.getBookmarks();
    });
  }

  Future<void> removeBookmark(Berita berita) async {
    await LocalService.removeBookmark(berita.id);
    await reloadBookmarks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${berita.title} dihapus dari bookmark'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> openDetail(Berita berita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          berita: berita,
          isFavorite: true,
          onFavoriteChanged: (item) async {
            await LocalService.toggleBookmark(item);
          },
        ),
      ),
    );
    await reloadBookmarks();
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
                  const Text('Tidak dapat memuat daftar bookmark.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: reloadBookmarks,
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }

          final beritas = snapshot.data ?? [];
          if (beritas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada berita yang disimpan.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: beritas.length,
            itemBuilder: (context, index) {
              final berita = beritas[index];
              return Dismissible(
                key: ValueKey(berita.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.only(right: 22),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => removeBookmark(berita),
                child: BeritaCard(
                  berita: berita,
                  isFavorite: true,
                  onTap: () => openDetail(berita),
                  onFavorite: () => removeBookmark(berita),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
