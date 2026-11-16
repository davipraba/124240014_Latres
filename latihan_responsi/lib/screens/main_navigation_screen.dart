import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import 'auth/login_screen.dart';
import 'episode/episode_screen.dart';
import 'favorite/favorite_screen.dart';
import 'home/home_screen.dart';

// Halaman Utama dengan Bottom Navigation Bar (Home, Favorite, Episode)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Indeks tab yang sedang aktif dipilih (0 = Characters, 1 = Favorites, 2 = Episodes)
  int _selectedIndex = 0;

  // Fungsi untuk berpindah tab saat item BottomNavigationBar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Dialog konfirmasi sebelum melakukan logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          // Tombol Keluar (Logout)
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              // Hapus sesi di SharedPreferences dan reset status login
              await authProvider.logout();
              if (mounted) {
                // Arahkan kembali ke Halaman Login dan bersihkan tumpukan route
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favProvider = Provider.of<FavoriteProvider>(context);

    // Judul AppBar yang dinamis mengikuti tab yang sedang dibuka
    final titles = [
      'Rick & Morty',
      'Favorites',
      'Episodes View',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (authProvider.username != null)
              Text(
                'Halo, ${authProvider.username}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          // Tombol Logout di pojok kanan atas AppBar
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      // IndexedStack menjaga keadaan halaman agar data tidak reload ulang saat ganti tab
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          FavoriteScreen(
            onExplorePressed: () => _onItemTapped(0), // Navigasi ke Home jika tombol jelajahi diklik
          ),
          const EpisodeScreen(),
        ],
      ),
      // Bottom Navigation Bar untuk berpindah antar 3 halaman
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF00B0C8),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            // Badge menampilkan jumlah karakter favorit yang aktif tersimpan
            icon: Badge(
              isLabelVisible: favProvider.count > 0,
              label: Text('${favProvider.count}'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            activeIcon: Badge(
              isLabelVisible: favProvider.count > 0,
              label: Text('${favProvider.count}'),
              child: const Icon(Icons.favorite_rounded),
            ),
            label: 'Favorites',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.tv_outlined),
            activeIcon: Icon(Icons.tv_rounded),
            label: 'Episodes',
          ),
        ],
      ),
    );
  }
}
