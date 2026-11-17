import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/preference_service.dart';

// Provider untuk mengelola status autentikasi pengguna (Login, Register, Logout)
class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PreferenceService _prefService = PreferenceService.instance;

  bool _isLoggedIn = false;
  String? _username;
  bool _isLoading = false;
  String? _errorMessage;

  // Getter variabel state agar bisa dibaca oleh widget/UI
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    checkAuthStatus();
  }

  // Fungsi mengecek sesi login saat aplikasi berjalan
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _prefService.isLoggedIn();
      if (_isLoggedIn) {
        _username = await _prefService.getUsername();
      } else {
        _username = null;
      }
    } catch (_) {
      _isLoggedIn = false;
      _username = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi proses Login pengguna
  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Username dan password tidak boleh kosong';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Cek user di Local Database (SQLite)
      final user = await _dbHelper.loginUser(username.trim(), password);

      if (user != null) {
        // 2. Jika valid, simpan status sesi ke SharedPreferences
        await _prefService.saveLoginSession(user.username);
        _isLoggedIn = true;
        _username = user.username;
        _isLoading = false;
        notifyListeners(); // Memperbarui tampilan UI
        return true;
      } else {
        _errorMessage = 'Username atau password salah!';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fungsi proses Registrasi akun baru
  Future<bool> register(
    String username,
    String password,
    String confirmPassword,
  ) async {
    final cleanUsername = username.trim();

    // Validasi input
    if (cleanUsername.isEmpty || password.isEmpty) {
      _errorMessage = 'Semua kolom wajib diisi';
      notifyListeners();
      return false;
    }

    // Validasi username biasa atau email
    if (cleanUsername.contains('@')) {
      final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
      if (!emailRegex.hasMatch(cleanUsername)) {
        _errorMessage = 'Format email tidak valid';
        notifyListeners();
        return false;
      }
    } else if (cleanUsername.length < 3) {
      _errorMessage = 'Username minimal 3 karakter';
      notifyListeners();
      return false;
    }

    // Validasi password minimal 8 karakter
    if (password.length < 8) {
      _errorMessage = 'Password minimal 8 karakter';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Konfirmasi password tidak cocok';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simpan user baru ke database SQLite
      final isSuccess = await _dbHelper.registerUser(
        UserModel(username: cleanUsername, password: password),
      );

      _isLoading = false;
      if (isSuccess) {
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            'Username atau email sudah digunakan, silakan pilih yang lain!';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal mendaftar: $e';
      notifyListeners();
      return false;
    }
  }

  // Fungsi Logout pengguna
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // Menghapus data sesi dari SharedPreferences
    await _prefService.clearSession();
    _isLoggedIn = false;
    _username = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
