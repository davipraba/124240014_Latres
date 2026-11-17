import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class WishlistDatabase {
  WishlistDatabase._();

  static final WishlistDatabase instance = WishlistDatabase._();
  static const String _webKey = 'shoppinghub_wishlist_ids';
  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'shoppinghub.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE wishlist (product_id INTEGER PRIMARY KEY)',
        );
      },
    );
    return _database!;
  }

  Future<Set<int>> getProductIds() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_webKey);
      if (value == null || value.isEmpty) return {};
      return (jsonDecode(value) as List<dynamic>).cast<int>().toSet();
    }

    final rows = await (await _db).query('wishlist');
    return rows.map((row) => row['product_id'] as int).toSet();
  }

  Future<void> saveProductIds(Set<int> productIds) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_webKey, jsonEncode(productIds.toList()));
      return;
    }

    final db = await _db;
    await db.transaction((transaction) async {
      await transaction.delete('wishlist');
      for (final id in productIds) {
        await transaction.insert('wishlist', {'product_id': id});
      }
    });
  }
}
