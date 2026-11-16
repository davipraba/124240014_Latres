import 'dart:async';
import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';

// Provider untuk mengelola daftar karakter di Home Screen
// Mendukung pemuatan data API, filter status (Alive, Dead, Unknown), dan pencarian nama karakter
class CharacterProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  List<CharacterModel> _characters = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _statusFilter = 'All'; // Nilai: 'All', 'Alive', 'Dead', 'unknown'
  String _searchQuery = '';
  Timer? _debounceTimer;

  List<CharacterModel> get characters => _characters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  CharacterProvider() {
    fetchCharacters();
  }

  // Fungsi mengambil daftar karakter dari API sesuai filter dan kata kunci pencarian
  Future<void> fetchCharacters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? statusParam =
          (_statusFilter == 'All') ? null : _statusFilter.toLowerCase();
      final String? nameParam =
          _searchQuery.trim().isEmpty ? null : _searchQuery.trim();

      // Panggil service API
      final results = await _apiService.getCharacters(
        page: 1,
        status: statusParam,
        name: nameParam,
      );

      _characters = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _characters = [];
      notifyListeners();
    }
  }

  // Mengubah filter status karakter (Alive, Dead, Unknown, atau Semua)
  void setStatusFilter(String status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    fetchCharacters(); // Ambil ulang data dari API sesuai filter baru
  }

  // Fungsi pencarian dengan jeda debounce (500ms) agar tidak membebani panggilan API
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        _searchQuery = query;
        fetchCharacters();
      }
    });
  }

  // Menghapus kata kunci pencarian
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    fetchCharacters();
  }

  // Memuat ulang data (pull to refresh)
  Future<void> refresh() async {
    await fetchCharacters();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
