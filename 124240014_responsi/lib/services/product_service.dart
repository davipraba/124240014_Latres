import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  Future<List<ProductModel>> getProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl?limit=10'));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat produk (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final products = data['products'] as List<dynamic>;
    return products
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories'));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat kategori (${response.statusCode})');
    }

    final categories = jsonDecode(response.body) as List<dynamic>;
    return categories.map((item) {
      if (item is String) return item;
      return (item as Map<String, dynamic>)['slug'] as String;
    }).toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat detail produk (${response.statusCode})');
    }
    return ProductModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
