import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_model.dart';

// Service untuk mengelola data yang disimpan ke SharedPreferences:
// 1. Sesi Login pengguna (agar tetap login saat aplikasi dibuka kembali)
// 2. Daftar Karakter Favorit (agar data favorit tidak hilang saat aplikasi ditutup)
class PreferenceService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'logged_in_username';
  static const String _keyFavorites = 'favorite_characters';

  // Singleton instance agar bisa diakses langsung lewat PreferenceService.instance
  static final PreferenceService instance = PreferenceService._init();
  PreferenceService._init();

  // --- 1. Manajemen Sesi Login ---

  // Menyimpan status login dan username pengguna saat berhasil login
  Future<void> saveLoginSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  // Mengecek apakah pengguna saat ini sedang login atau tidak
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Mengambil username pengguna yang sedang aktif login
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // Menghapus status login saat pengguna menekan tombol logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUsername);
  }

  // --- 2. Manajemen Karakter Favorit (Disimpan di SharedPreferences) ---

  // Mengambil seluruh daftar karakter favorit dari SharedPreferences
  Future<List<CharacterModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyFavorites);

    // Jika belum ada data favorit yang tersimpan, kembalikan list kosong
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      // Mengubah string JSON menjadi List of Map lalu diubah ke List<CharacterModel>
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => CharacterModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Menyimpan list karakter favorit ke SharedPreferences dalam bentuk string JSON
  Future<void> saveFavorites(List<CharacterModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapList =
        favorites.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(mapList);
    await prefs.setString(_keyFavorites, jsonString);
  }

  // Menambahkan karakter ke dalam daftar favorit
  Future<bool> addFavorite(CharacterModel character) async {
    final favorites = await getFavorites();
    // Cek apakah karakter sudah ada di favorit sebelumnya
    if (!favorites.any((c) => c.id == character.id)) {
      favorites.add(character);
      await saveFavorites(favorites);
      return true; // Berhasil ditambahkan
    }
    return false; // Karakter sudah ada di favorit
  }

  // Menghapus karakter dari daftar favorit berdasarkan ID karakter
  Future<bool> removeFavorite(int characterId) async {
    final favorites = await getFavorites();
    final initialLength = favorites.length;
    favorites.removeWhere((c) => c.id == characterId);

    // Jika panjang list berkurang, berarti data berhasil dihapus
    if (favorites.length != initialLength) {
      await saveFavorites(favorites);
      return true;
    }
    return false;
  }

  // Mengecek apakah suatu karakter tertentu berstatus favorit atau tidak
  Future<bool> isFavorite(int characterId) async {
    final favorites = await getFavorites();
    return favorites.any((c) => c.id == characterId);
  }
}
