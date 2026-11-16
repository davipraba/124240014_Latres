import 'package:flutter/material.dart';
import '../models/episode_model.dart';
import '../services/api_service.dart';

// Provider untuk mengelola daftar episode di Episode Screen
class EpisodeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;

  List<EpisodeModel> _episodes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EpisodeModel> get episodes => _episodes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EpisodeProvider() {
    fetchEpisodes();
  }

  // Mengambil data episode dari endpoint /episode
  Future<void> fetchEpisodes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.getEpisodes();
      _episodes = results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _episodes = [];
      notifyListeners();
    }
  }

  // Memuat ulang daftar episode (pull-to-refresh)
  Future<void> refresh() async {
    await fetchEpisodes();
  }
}
