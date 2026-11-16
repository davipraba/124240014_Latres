import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/preference_service.dart';

// Provider untuk mengelola Karakter Favorit
// Menggunakan SharedPreferences agar data favorit tidak hilang saat aplikasi ditutup
// Provider ini memastikan perubahan favorit langsung ter-update di Home Screen dan Favorite Screen secara bersamaan
class FavoriteProvider extends ChangeNotifier {
  final PreferenceService _preferenceService = PreferenceService.instance;

  List<CharacterModel> _favorites = [];
  bool _isLoading = false;

  List<CharacterModel> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  bool get isEmpty => _favorites.isEmpty;
  int get count => _favorites.length;

  FavoriteProvider() {
    loadFavorites();
  }

  // Mengambil data favorit dari SharedPreferences saat pertama kali dijalankan
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _preferenceService.getFavorites();
    } catch (_) {
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengecek apakah suatu karakter tertentu adalah favorit
  bool isFavorite(int characterId) {
    return _favorites.any((c) => c.id == characterId);
  }

  // Toggle status favorit: jika sudah ada maka dihapus, jika belum ada maka ditambahkan
  // Mengembalikan true jika ditambahkan, false jika dihapus
  Future<bool> toggleFavorite(CharacterModel character) async {
    final exists = isFavorite(character.id);
    if (exists) {
      _favorites.removeWhere((c) => c.id == character.id);
      await _preferenceService.saveFavorites(_favorites);
      notifyListeners(); // Notifikasi ke semua halaman agar UI langsung ter-update
      return false; // Dihapus dari favorit
    } else {
      _favorites.add(character);
      await _preferenceService.saveFavorites(_favorites);
      notifyListeners(); // Notifikasi ke semua halaman agar UI langsung ter-update
      return true; // Ditambahkan ke favorit
    }
  }

  // Menghapus karakter dari favorit (dipakai saat swipe di halaman Favorite Screen)
  Future<void> removeFavorite(int characterId) async {
    _favorites.removeWhere((c) => c.id == characterId);
    await _preferenceService.saveFavorites(_favorites);
    notifyListeners();
  }

  // Menambahkan karakter ke favorit (dipakai juga untuk fitur undo/batalkan penghapusan)
  Future<void> addFavorite(CharacterModel character) async {
    if (!isFavorite(character.id)) {
      _favorites.add(character);
      await _preferenceService.saveFavorites(_favorites);
      notifyListeners();
    }
  }
}
