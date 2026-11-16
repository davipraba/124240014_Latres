import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/character_model.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/status_badge.dart';

// Halaman Detail Karakter: Foto, nama, status, spesies, gender, origin, lokasi, dan tombol favorit
class DetailScreen extends StatelessWidget {
  final CharacterModel character;

  const DetailScreen({
    super.key,
    required this.character,
  });

  // Fungsi toggle favorit (tambah atau hapus) dan menampilkan Snackbar
  void _toggleFavorite(BuildContext context, FavoriteProvider favProvider) async {
    final wasAdded = await favProvider.toggleFavorite(character);
    if (context.mounted) {
      // Tampilkan SnackBar sesuai aksi
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasAdded
                ? '${character.name} ditambahkan ke favorit!'
                : '${character.name} dihapus dari favorit',
          ),
          backgroundColor:
              wasAdded ? const Color(0xFF10B981) : Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        // Cek status apakah karakter ini sudah difavoritkan
        final isFav = favProvider.isFavorite(character.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(character.name),
            actions: [
              // Ikon Favorit di AppBar yang berubah bentuk & warna
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.grey.shade700,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () => _toggleFavorite(context, favProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Foto Karakter Ukuran Besar
                Hero(
                  tag: 'char_img_${character.id}',
                  child: SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: Image.network(
                      character.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, size: 80, color: Colors.grey),
                    ),
                  ),
                ),

                // 2. Konten Informasi Karakter
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Karakter & Badge Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              character.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusBadge(status: character.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      const Text(
                        'Informasi Karakter',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Tile Spesies
                      _buildInfoTile(
                        icon: Icons.fingerprint_rounded,
                        label: 'Spesies',
                        value: character.species +
                            (character.type.isNotEmpty ? ' (${character.type})' : ''),
                      ),
                      const SizedBox(height: 10),

                      // Tile Gender
                      _buildInfoTile(
                        icon: Icons.wc_rounded,
                        label: 'Gender',
                        value: character.gender,
                      ),
                      const SizedBox(height: 10),

                      // Tile Origin (Asal Karakter)
                      _buildInfoTile(
                        icon: Icons.public_rounded,
                        label: 'Origin (Asal)',
                        value: character.originName,
                      ),
                      const SizedBox(height: 10),

                      // Tile Location (Lokasi Saat Ini)
                      _buildInfoTile(
                        icon: Icons.location_on_rounded,
                        label: 'Location (Lokasi)',
                        value: character.locationName,
                      ),
                      const SizedBox(height: 10),

                      // Tile Jumlah Kemunculan Episode
                      _buildInfoTile(
                        icon: Icons.movie_outlined,
                        label: 'Kemunculan Episode',
                        value: '${character.episodeCount} Episode',
                      ),

                      const SizedBox(height: 28),

                      // 3. Tombol Aksi Tambah / Hapus Favorit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleFavorite(context, favProvider),
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          label: Text(
                            isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFav
                                ? Colors.redAccent
                                : const Color(0xFF00B0C8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget untuk membuat baris informasi dengan ikon, judul, dan nilai
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF00B0C8)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
