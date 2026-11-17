import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/wishlist_database.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  final WishlistDatabase _wishlistDatabase = WishlistDatabase.instance;

  List<ProductModel> _products = [];
  List<String> _categories = [];
  Set<int> _wishlistIds = {};
  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;

  List<ProductModel> get products => List.unmodifiable(_products);
  List<String> get categories => ['Semua', ..._categories];
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get wishlistCount => _wishlistIds.length;

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'Semua') return products;
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  List<ProductModel> get wishlistProducts =>
      _products.where((product) => _wishlistIds.contains(product.id)).toList();

  ProductProvider() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getProducts(),
        _service.getCategories(),
        _wishlistDatabase.getProductIds(),
      ]);
      _products = results[0] as List<ProductModel>;
      _categories = results[1] as List<String>;
      _wishlistIds = results[2] as Set<int>;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  bool isWishlisted(int productId) => _wishlistIds.contains(productId);

  Future<void> toggleWishlist(ProductModel product) async {
    final updatedIds = Set<int>.from(_wishlistIds);
    if (!updatedIds.add(product.id)) {
      updatedIds.remove(product.id);
    }
    await _wishlistDatabase.saveProductIds(updatedIds);
    _wishlistIds = updatedIds;
    notifyListeners();
  }
}
