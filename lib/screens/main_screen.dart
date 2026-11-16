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
  int selectedIndex = 0;
  String searchText = '';
  final searchController = TextEditingController();
  late Future<List<Berita>> beritaFuture;
  List<int> favoriteIds = [];
  String username = 'Pengguna';

  @override
  void initState() {
    super.initState();
    beritaFuture = ApiService.getBerita();
    loadLocalData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadLocalData() async {
    final id = await LocalService.getFavorites();
    final titles = await LocalService.getUsername();
    if (mounted) {
      setState(() {
        favoriteIds = id;
        titles = title;
      });
    }
  }

  void loadBerita() {
    setState(() {
      beritaFuture = ApiService.getBerita(title: searchText);
    });
  }

  Future<void> toggleFavorite(int id) async {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
    await LocalService.saveFavorites(favoriteIds);
  }

  Future<void> openDetail(Berita berita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          id: berita.id,
          isFavorite: favoriteIds.contains(berita.id),
          onFavoriteChanged: toggleFavorite,
        ),
      ),
    );
    loadLocalData();
  }

  Future<void> logout() async {
    await LocalService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'Explore Berita' : 'My Favorites'),
        actions: [
          IconButton(
            tooltip: 'Bookmark',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookmarkScreen()),
            ),
            icon: const Icon(Icons.movie_outlined),
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
      body: selectedIndex == 0 ? buildHome() : buildFavorites(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
          loadLocalData();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              searchText = value;
              loadBerita();
            },
            decoration: InputDecoration(
              hintText: 'Cari nama Berita...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  searchController.clear();
                  searchText = '';
                  loadBerita();
                },
                icon: const Icon(Icons.close),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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
                          'Gagal memuat karakter. Periksa koneksi internet.',
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
                    onFavorite: () => toggleFavorite(berita.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildFavorites() {
    if (favoriteIds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada berita favorit.'),
          ],
        ),
      );
    }
    return FutureBuilder<List<Berita>>(
      future: Future.wait(
        favoriteIds.map((id) => ApiService.getBeritaDetail(id)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Gagal memuat daftar favorit.'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }
        final beritas = snapshot.data ?? [];
        if (beritas.isEmpty) {
          return const Center(child: Text('Belum ada berita favorit.'));
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
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                await toggleFavorite(berita.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${berita.title} dihapus dari favorit'),
                    ),
                  );
                }
              },
              child: BeritaCard(
                berita: berita,
                isFavorite: true,
                onTap: () => openDetail(berita),
                onFavorite: () async {
                  await toggleFavorite(berita.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${berita.title} dihapus dari favorit'),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
