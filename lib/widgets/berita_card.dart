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
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 112,
                height: 112,
                color: Colors.black12,
                child: const Icon(Icons.person, size: 40),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
