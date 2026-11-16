import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../models/episode_model.dart';

// Service untuk melakukan HTTP Request ke REST API resmi Rick & Morty
class ApiService {
  // Base URL utama API Rick & Morty
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  static final ApiService instance = ApiService._init();
  ApiService._init();

  // 1. Mengambil daftar karakter dengan dukungan filter status dan pencarian nama
  // Parameter status: 'alive', 'dead', 'unknown', atau null untuk semua
  // Parameter name: nama karakter yang dicari
  Future<List<CharacterModel>> getCharacters({
    int page = 1,
    String? status,
    String? name,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };

    // Tambahkan filter status jika dipilih selain 'All'
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }

    // Tambahkan parameter pencarian jika kolom cari diisi
    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] as List<dynamic>;
        return results
            .map((item) => CharacterModel.fromApiJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        // API Rick & Morty mengembalikan kode 404 jika hasil pencarian tidak ditemukan
        return [];
      } else {
        throw HttpException('Gagal memuat karakter (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException || e is SocketException) rethrow;
      throw Exception('Terjadi kesalahan saat memuat data: $e');
    }
  }

  // 2. Mengambil detail lengkap karakter berdasarkan ID
  Future<CharacterModel> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CharacterModel.fromApiJson(data as Map<String, dynamic>);
      } else {
        throw HttpException('Karakter tidak ditemukan (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException || e is SocketException) rethrow;
      throw Exception('Gagal memuat detail karakter: $e');
    }
  }

  // 3. Mengambil daftar episode serial Rick & Morty
  Future<List<EpisodeModel>> getEpisodes({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/episode?page=$page');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] as List<dynamic>;
        return results
            .map((item) => EpisodeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw HttpException('Gagal memuat episode (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException || e is SocketException) rethrow;
      throw Exception('Gagal memuat daftar episode: $e');
    }
  }
}
