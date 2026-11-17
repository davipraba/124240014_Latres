import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';

// Helper untuk mengelola Local Database (menyimpan data registrasi & login user)
// Mendukung SQLite di Android/iOS/Desktop dan penyimpanan lokal di Web
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const String _webUsersKey = 'local_db_users_table';

  DatabaseHelper._init();

  // Getter untuk mengambil instance database SQLite (dibuat sekali saja / lazy loading)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rick_morty.db');
    return _database!;
  }

  // Fungsi inisialisasi file database SQLite
  Future<Database> _initDB(String filePath) async {
    // Inisialisasi engine FFI jika dijalankan di sistem operasi desktop
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(path, version: 1, onCreate: _createDB);

    // Memastikan akun default 'admin' sudah tersedia untuk kemudahan pengujian
    final existingAdmin = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: ['admin'],
    );
    if (existingAdmin.isEmpty) {
      await db.insert('users', {'username': 'admin', 'password': 'admin123'});
    }

    return db;
  }

  // Fungsi pembuatan tabel users saat database pertama kali dibuat
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Menambahkan akun default admin
    await db.insert('users', {'username': 'admin', 'password': 'admin123'});
  }

  // --- Penanganan Khusus Jika Dijalankan di Web Browser ---

  // Mengambil daftar user dari penyimpanan lokal browser
  Future<List<Map<String, dynamic>>> _getWebUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_webUsersKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      // Akun default untuk web
      final defaultUsers = [
        {'id': 1, 'username': 'admin', 'password': 'admin123'},
      ];
      await prefs.setString(_webUsersKey, jsonEncode(defaultUsers));
      return defaultUsers;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // Menyimpan daftar user ke penyimpanan lokal browser
  Future<void> _saveWebUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webUsersKey, jsonEncode(users));
  }

  // --- Fungsi Registrasi & Login ---

  // Mendaftarkan user baru ke dalam local database
  Future<bool> registerUser(UserModel user) async {
    final cleanUsername = user.username.trim();

    // Jika berjalan di browser web
    if (kIsWeb) {
      final users = await _getWebUsers();
      final exists = users.any(
        (u) =>
            (u['username'] as String).toLowerCase() ==
            cleanUsername.toLowerCase(),
      );

      // Jika username sudah terdaftar
      if (exists) return false;

      final nextId = users.isEmpty ? 1 : (users.last['id'] as int) + 1;
      users.add({
        'id': nextId,
        'username': cleanUsername,
        'password': user.password,
      });

      await _saveWebUsers(users);
      return true;
    }

    // Jika berjalan di Android / iOS / Desktop (Menggunakan SQLite)
    try {
      final db = await database;
      final existing = await db.query(
        'users',
        where: 'LOWER(username) = ?',
        whereArgs: [cleanUsername.toLowerCase()],
      );

      // Jika username sudah digunakan
      if (existing.isNotEmpty) {
        return false;
      }

      // Simpan user baru ke tabel database
      await db.insert('users', {
        'username': cleanUsername,
        'password': user.password,
      });
      return true;
    } catch (e) {
      debugPrint('Error register: $e');
      rethrow;
    }
  }

  // Mengecek login user berdasarkan kecocokan username dan password di database
  Future<UserModel?> loginUser(String username, String password) async {
    final cleanUsername = username.trim();

    // Jika berjalan di web browser
    if (kIsWeb) {
      final users = await _getWebUsers();
      for (final u in users) {
        if ((u['username'] as String).toLowerCase() ==
                cleanUsername.toLowerCase() &&
            u['password'] == password) {
          return UserModel(
            id: u['id'] as int?,
            username: u['username'] as String,
            password: u['password'] as String,
          );
        }
      }
      return null;
    }

    // Jika berjalan di Android / iOS / Desktop (Query SQLite)
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'LOWER(username) = ? AND password = ?',
        whereArgs: [cleanUsername.toLowerCase(), password],
      );

      if (result.isNotEmpty) {
        return UserModel.fromMap(result.first);
      }
      return null; // Login gagal (username/password salah)
    } catch (e) {
      debugPrint('Error login: $e');
      return null;
    }
  }

  // Menutup koneksi database jika diperlukan
  Future<void> close() async {
    if (!kIsWeb) {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
      }
    }
  }
}
