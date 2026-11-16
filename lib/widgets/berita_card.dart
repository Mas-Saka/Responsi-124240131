import 'package:flutter/material.dart';
import '../models/berita.dart';

class BeritaCard extends StatelessWidget {
  final Berita berita;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const BeritaCard({
    super.key,
    required this.berita,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  String formatDate(String value) {
    if (value.isEmpty || value == '-') return 'Tanggal tidak tersedia';
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Image.network(
              berita.image_url,
              width: 112,
              height: 126,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 112,
                height: 126,
                color: Colors.black12,
                child: const Icon(Icons.rocket_launch, size: 38),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      berita.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      berita.news_site,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF247A58),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(berita.published_at),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: isFavorite ? 'Hapus bookmark' : 'Tambah bookmark',
              onPressed: onFavorite,
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: isFavorite ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
