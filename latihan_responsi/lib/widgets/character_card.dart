import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character_model.dart';
import '../providers/favorite_provider.dart';
import 'status_badge.dart';

// Widget Kartu Karakter yang menampilkan foto, nama, status, dan tombol favorit
class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer FavoriteProvider agar ikon favorit langsung ter-update
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final isFav = favProvider.isFavorite(character.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            onTap: onTap, // Aksi ketika seluruh kartu ditekan (pindah ke Detail Screen)
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Foto Karakter dengan animasi Hero
                  Hero(
                    tag: 'char_img_${character.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey.shade200,
                        child: Image.network(
                          character.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 36, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Informasi Nama, Status, dan Spesies
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatusBadge(status: character.status, compact: true),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                character.species,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tombol Ikon Favorit (Hati)
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.redAccent : Colors.grey.shade400,
                      size: 26,
                    ),
                    onPressed: () async {
                      // Toggle status favorit di SharedPreferences melalui Provider
                      final wasAdded = await favProvider.toggleFavorite(character);

                      // Tampilkan notifikasi Snackbar
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              wasAdded
                                  ? '${character.name} ditambahkan ke favorit!'
                                  : '${character.name} dihapus dari favorit',
                            ),
                            backgroundColor: wasAdded
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
