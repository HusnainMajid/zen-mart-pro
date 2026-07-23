import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/vendor_product_service.dart';

class VendorProductProvider with ChangeNotifier {
  final VendorProductService _productService = VendorProductService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String _stockStatus = 'all'; // 'all', 'in_stock', 'out_of_stock'

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for filters
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get stockStatus => _stockStatus;

  /// Fetches all products for a specific shop.
  Future<void> fetchShopProducts(String shopId) async {
    _setLoading(true);
    try {
      _allProducts = await _productService.getShopProducts(shopId);
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      debugPrint('Provider error fetching products: $e');
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null || product.categoryId == _selectedCategory;
      
      final matchesPrice = (product.price >= (_minPrice ?? 0)) &&
          (_maxPrice == null || product.price <= _maxPrice!);
      
      bool matchesStock = true;
      if (_stockStatus == 'in_stock') {
        matchesStock = product.stock > 0;
      } else if (_stockStatus == 'out_of_stock') {
        matchesStock = product.stock == 0;
      }

      return matchesSearch && matchesCategory && matchesPrice && matchesStock;
    }).toList();
    notifyListeners();
  }

  /// Sets search query and applies filters.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Sets filters and applies them.
  void setFilters({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? stockStatus,
  }) {
    if (categoryId != null) _selectedCategory = categoryId == 'all' ? null : categoryId;
    if (minPrice != null) _minPrice = minPrice;
    if (maxPrice != null) _maxPrice = maxPrice;
    if (stockStatus != null) _stockStatus = stockStatus;
    _applyFilters();
  }

  /// Clears all filters.
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _stockStatus = 'all';
    _applyFilters();
  }

  /// Adds a new product.
  Future<bool> addProduct(ProductModel product) async {
    _setLoading(true);
    try {
      final newProduct = product.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
      );

      await _productService.addProduct(newProduct);
      await fetchShopProducts(product.shopId);
      
      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Provider error adding product: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing product.
  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    try {
      await _productService.updateProduct(product);
      await fetchShopProducts(product.shopId);
      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Provider error updating product: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a product.
  Future<bool> deleteProduct(ProductModel product) async {
    _setLoading(true);
    try {
      await _productService.deleteProduct(product.id);
      await fetchShopProducts(product.shopId);
      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Provider error deleting product: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Duplicates an existing product.
  Future<bool> duplicateProduct(ProductModel product) async {
    _setLoading(true);
    try {
      final duplicatedProduct = product.copyWith(
        id: const Uuid().v4(),
        name: '${product.name} (Copy)',
        sku: '${product.sku}-COPY',
        createdAt: DateTime.now(),
      );
      await _productService.addProduct(duplicatedProduct);
      await fetchShopProducts(product.shopId);
      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Provider error duplicating product: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Archives a product.
  Future<bool> archiveProduct(ProductModel product) async {
    _setLoading(true);
    try {
      // Logic for archiving (setting stock to 0 or similar)
      final archivedProduct = product.copyWith(stock: 0);
      await _productService.updateProduct(archivedProduct);
      await fetchShopProducts(product.shopId);
      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Provider error archiving product: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Auto-generates a SKU based on category and shop name.
  String generateSKU(String categoryName, String shopName) {
    final catPrefix = categoryName.length >= 3 ? categoryName.substring(0, 3).toUpperCase() : categoryName.toUpperCase();
    final shopPrefix = shopName.length >= 2 ? shopName.substring(0, 2).toUpperCase() : shopName.toUpperCase();
    final random = const Uuid().v4().substring(0, 4).toUpperCase();
    return '$shopPrefix-$catPrefix-$random';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
