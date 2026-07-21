import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/admin_product_service.dart';

class AdminProductProvider with ChangeNotifier {
  final AdminProductService _productService = AdminProductService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedShop;

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all products across all shops.
  Future<void> fetchAllProducts() async {
    _setLoading(true);
    try {
      _allProducts = await _productService.getAllProducts();
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Sets search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Sets category filter and applies filters.
  void setCategoryFilter(String? categoryId) {
    _selectedCategory = categoryId;
    _applyFilters();
  }

  /// Sets shop filter and applies filters.
  void setShopFilter(String? shopId) {
    _selectedShop = shopId;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || product.categoryId == _selectedCategory;
      final matchesShop = _selectedShop == null || product.shopId == _selectedShop;
      return matchesSearch && matchesCategory && matchesShop;
    }).toList();
    notifyListeners();
  }

  /// Deletes a product.
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    try {
      await _productService.deleteProduct(productId);
      await fetchAllProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedShop = null;
    _filteredProducts = List.from(_allProducts);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
