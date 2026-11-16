import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/auth_provider.dart';
import 'providers/character_provider.dart';
import 'providers/episode_provider.dart';
import 'providers/favorite_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

// Fungsi utama aplikasi yang dijalankan pertama kali
void main() async {
  // Memastikan semua binding widget Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi library SQLite FFI jika aplikasi dijalankan di Desktop (Windows/Linux/macOS)
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // Cek sesi login langsung dari SharedPreferences
  // Jika sudah login, langsung ke halaman utama. Jika belum, ke halaman login.
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(RickAndMortyApp(isLoggedIn: isLoggedIn));
}

class RickAndMortyApp extends StatelessWidget {
  final bool isLoggedIn;

  const RickAndMortyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // MultiProvider digunakan untuk mendaftarkan semua Provider (State Management)
    // agar bisa diakses oleh seluruh halaman/widget di bawahnya
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create: (_) => EpisodeProvider()),
      ],
      child: MaterialApp(
        title: 'Rick & Morty Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00B0C8),
            primary: const Color(0xFF00B0C8),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        ),
        // Langsung arahkan ke halaman utama jika sudah login, atau ke Login jika belum
        home: isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
      ),
    );
  }
}
