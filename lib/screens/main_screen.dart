import 'package:flutter/material.dart';
import '../models/berita.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
import '../widgets/berita_card.dart';
import 'detail_berita_screen.dart';
import 'bookmark_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<Berita>> beritaFuture;

  List<int> favoriteIds = [];
  List<String> newsSites = [];
  String username = 'Pengguna';
  String selectedNewsSite = '';

  @override
  void initState() {
    super.initState();
    beritaFuture = ApiService.getBerita();
    loadLocalData();
    loadNewsSites();
  }

  Future<void> loadLocalData() async {
    final ids = await LocalService.getFavorites();
    final user = await LocalService.getUsername();

    if (mounted) {
      setState(() {
        favoriteIds = ids;
        username = user;
      });
    }
  }

  Future<void> loadNewsSites() async {
    try {
      final articles = await ApiService.getBerita();
      final sites =
          articles
              .map((article) => article.news_site)
              .where((site) => site.isNotEmpty && site != '-')
              .toSet()
              .toList()
            ..sort();

      if (mounted) {
        setState(() => newsSites = sites);
      }
    } catch (_) {
      // Daftar sumber akan tetap kosong jika API sedang tidak tersedia.
    }
  }

  void loadBerita() {
    setState(() {
      beritaFuture = ApiService.getBerita(news_site: selectedNewsSite);
    });
  }

  Future<void> toggleFavorite(Berita berita) async {
    await LocalService.toggleBookmark(berita);
    await loadLocalData();
  }

  Future<void> openDetail(Berita berita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          berita: berita,
          isFavorite: favoriteIds.contains(berita.id),
          onFavoriteChanged: toggleFavorite,
        ),
      ),
    );
    await loadLocalData();
  }

  Future<void> logout() async {
    await LocalService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $username'),
        actions: [
          IconButton(
            tooltip: 'Bookmark',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkScreen()),
              );
              await loadLocalData();
            },
            icon: const Icon(Icons.bookmark_outline),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'username',
                enabled: false,
                child: Text(username),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: buildHome(),
    );
  }

  Widget buildHome() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: DropdownButtonFormField<String>(
            value: selectedNewsSite.isEmpty ? '' : selectedNewsSite,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Filter sumber berita',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Semua sumber')),
              ...newsSites.map(
                (site) => DropdownMenuItem(
                  value: site,
                  child: Text(site, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (value) {
              selectedNewsSite = value ?? '';
              loadBerita();
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Berita>>(
            future: beritaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Gagal memuat berita. Periksa koneksi internet.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: loadBerita,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final beritas = snapshot.data ?? [];
              if (beritas.isEmpty) {
                return const Center(child: Text('Berita tidak ditemukan.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: beritas.length,
                itemBuilder: (context, index) {
                  final berita = beritas[index];
                  return BeritaCard(
                    berita: berita,
                    isFavorite: favoriteIds.contains(berita.id),
                    onTap: () => openDetail(berita),
                    onFavorite: () async {
                      final wasFavorite = favoriteIds.contains(berita.id);
                      await toggleFavorite(berita);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasFavorite
                                ? 'Berita dihapus dari bookmark'
                                : 'Berita ditambahkan ke bookmark',
                          ),
                          backgroundColor: wasFavorite
                              ? Colors.red
                              : Colors.green,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
