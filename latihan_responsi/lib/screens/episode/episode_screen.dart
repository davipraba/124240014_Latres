import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/episode_provider.dart';
import '../../widgets/empty_or_error_widget.dart';

// Halaman Episode: Menampilkan daftar episode dari API (Nama, Air Date, Kode Episode)
class EpisodeScreen extends StatelessWidget {
  const EpisodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<EpisodeProvider>(
        builder: (context, provider, _) {
          // 1. Loading State saat data episode sedang diambil dari API
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B0C8)),
                  ),
                  SizedBox(height: 12),
                  Text('Memuat daftar episode...'),
                ],
              ),
            );
          }

          // 2. Error Handling jika API gagal diakses
          if (provider.errorMessage != null) {
            return EmptyOrErrorWidget(
              icon: Icons.error_outline_rounded,
              iconColor: const Color(0xFFEF4444),
              title: 'Gagal Memuat Episode',
              message: provider.errorMessage!,
              buttonText: 'Coba Lagi',
              onButtonPressed: () => provider.refresh(), // Tombol coba lagi
            );
          }

          // 3. Empty State jika tidak ada data episode
          if (provider.episodes.isEmpty) {
            return EmptyOrErrorWidget(
              icon: Icons.movie_filter_outlined,
              title: 'Tidak Ada Episode',
              message: 'Daftar episode tidak ditemukan.',
              buttonText: 'Muat Ulang',
              onButtonPressed: () => provider.refresh(),
            );
          }

          // 4. Menampilkan List Episode
          return RefreshIndicator(
            color: const Color(0xFF00B0C8),
            onRefresh: () => provider.refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.episodes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ep = provider.episodes[index];

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    // Kode Episode (misal: S01E01)
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B0C8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ep.episode.isNotEmpty ? ep.episode : '#${ep.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B0C8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Nama Episode
                    title: Text(
                      ep.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    // Tanggal Tayang Episode (air_date)
                    subtitle: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          ep.airDate,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
