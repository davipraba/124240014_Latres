import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character_provider.dart';
import '../../widgets/character_card.dart';
import '../../widgets/empty_or_error_widget.dart';
import '../../widgets/search_bar_widget.dart';
import '../detail/detail_screen.dart';

// Home Screen: Menampilkan daftar karakter, fitur filter status, dan pencarian nama (Bonus)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<CharacterProvider>(
        builder: (context, charProvider, _) {
          return Column(
            children: [
              // 1. Kolom Pencarian Karakter Berdasarkan Nama (Bonus)
              SearchBarWidget(
                hintText: 'Cari karakter berdasarkan nama...',
                onChanged: (query) => charProvider.onSearchChanged(query),
                onClear: () => charProvider.clearSearch(),
              ),

              // 2. Filter Status Karakter (Alive, Dead, Unknown, Semua)
              _buildFilterChips(context, charProvider),

              const SizedBox(height: 6),

              // 3. Tampilan Daftar Karakter / Loading / Error Handling
              Expanded(
                child: _buildBody(context, charProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget baris chip untuk memilih filter status
  Widget _buildFilterChips(BuildContext context, CharacterProvider provider) {
    final filters = [
      {'label': 'Semua', 'value': 'All', 'color': const Color(0xFF00B0C8)},
      {'label': 'Alive', 'value': 'Alive', 'color': const Color(0xFF10B981)},
      {'label': 'Dead', 'value': 'Dead', 'color': const Color(0xFFEF4444)},
      {'label': 'Unknown', 'value': 'unknown', 'color': const Color(0xFF6B7280)},
    ];

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected =
              provider.statusFilter.toLowerCase() == (filter['value'] as String).toLowerCase();
          final color = filter['color'] as Color;

          return ChoiceChip(
            label: Text(
              filter['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedColor: color,
            onSelected: (selected) {
              if (selected) {
                // Terapkan filter status yang dipilih
                provider.setStatusFilter(filter['value'] as String);
              }
            },
          );
        },
      ),
    );
  }

  // Widget body yang menangani loading state, error state, empty state, dan listview
  Widget _buildBody(BuildContext context, CharacterProvider provider) {
    // 1. Loading State saat API sedang mengambil data
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B0C8)),
            ),
            SizedBox(height: 12),
            Text('Memuat daftar karakter...'),
          ],
        ),
      );
    }

    // 2. Error Handling jika koneksi gagal atau API error
    if (provider.errorMessage != null) {
      return EmptyOrErrorWidget(
        icon: Icons.wifi_off_rounded,
        iconColor: const Color(0xFFEF4444),
        title: 'Gagal Memuat Karakter',
        message: provider.errorMessage!,
        buttonText: 'Coba Lagi',
        onButtonPressed: () => provider.refresh(), // Tombol coba lagi
      );
    }

    // 3. Empty State jika karakter tidak ditemukan berdasarkan filter/pencarian
    if (provider.characters.isEmpty) {
      return EmptyOrErrorWidget(
        icon: Icons.search_off_rounded,
        title: 'Karakter Tidak Ditemukan',
        message: 'Tidak ada karakter yang cocok dengan kriteria pencarian.',
        buttonText: 'Reset Pencarian',
        onButtonPressed: () {
          provider.clearSearch();
          provider.setStatusFilter('All');
        },
      );
    }

    // 4. Daftar Karakter Berhasil Dimuat (dengan fitur Pull-to-refresh)
    return RefreshIndicator(
      color: const Color(0xFF00B0C8),
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: provider.characters.length,
        itemBuilder: (context, index) {
          final character = provider.characters[index];
          return CharacterCard(
            character: character,
            onTap: () {
              // Navigasi ke Halaman Detail Karakter saat kartu diklik
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailScreen(character: character),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
