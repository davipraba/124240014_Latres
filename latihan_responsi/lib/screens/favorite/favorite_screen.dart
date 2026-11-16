import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/character_card.dart';
import '../../widgets/empty_or_error_widget.dart';
import '../detail/detail_screen.dart';

// Favorite Screen: Daftar karakter favorit yang disimpan di SharedPreferences
// Dilengkapi fitur swipe untuk menghapus dan empty state jika masih kosong
class FavoriteScreen extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const FavoriteScreen({
    super.key,
    this.onExplorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, _) {
          // Loading state saat membaca dari SharedPreferences
          if (favProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B0C8)),
              ),
            );
          }

          // Empty state: Pesan apabila daftar favorit masih kosong
          if (favProvider.isEmpty) {
            return EmptyOrErrorWidget(
              icon: Icons.favorite_border_rounded,
              iconColor: Colors.redAccent,
              title: 'Belum Ada Favorit',
              message:
                  'Daftar karakter favoritmu masih kosong.\nKlik ikon hati pada karakter untuk menyimpannya di sini.',
              buttonText: onExplorePressed != null ? 'Jelajahi Karakter' : null,
              onButtonPressed: onExplorePressed,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Petunjuk cara menghapus favorit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.amber.shade50,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Geser (swipe) ke kiri untuk menghapus dari favorit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Daftar Favorit dengan widget Dismissible (Swipe to Delete)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: favProvider.favorites.length,
                  itemBuilder: (context, index) {
                    final character = favProvider.favorites[index];

                    return Dismissible(
                      key: Key('fav_${character.id}'),
                      direction: DismissDirection.endToStart, // Arah geser dari kanan ke kiri
                      background: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444), // Warna merah saat digeser
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete_outline, color: Colors.white, size: 24),
                          ],
                        ),
                      ),
                      // Dipanggil setelah item berhasil di-swipe
                      onDismissed: (direction) {
                        // 1. Hapus dari SharedPreferences melalui Provider
                        favProvider.removeFavorite(character.id);

                        // 2. Tampilkan Snackbar konfirmasi penghapusan dengan tombol Batalkan (Undo)
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${character.name} dihapus dari favorit'),
                            action: SnackBarAction(
                              label: 'BATALKAN',
                              textColor: const Color(0xFF10B981),
                              onPressed: () {
                                // Kembalikan karakter ke favorit jika pengguna membatalkan
                                favProvider.addFavorite(character);
                              },
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: CharacterCard(
                        character: character,
                        onTap: () {
                          // Buka detail karakter saat diklik
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(character: character),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
