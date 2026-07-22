import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../services/vendor_product_service.dart';
import '../services/storage_service.dart';

class VendorProductProvider with ChangeNotifier {
  final VendorProductService _productService = VendorProductService();
  final StorageService _storageService = StorageService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String _searchQuery = '';
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  String _stockStatus = 'all'; // 'all', 'in_stock', 'low_stock', 'out_of_stock'
  bool _isFeaturedOnly = false;

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for filters
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get stockStatus => _stockStatus;
  bool get isFeaturedOnly => _isFeaturedOnly;

  /// Fetches all products for a specific shop.
  Future<void> fetchShopProducts(String shopId) async {
    _setLoading(true);
    try {
      _allProducts = await _productService.getShopProducts(shopId);
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
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
        matchesStock = product.stock > product.minStockAlert;
      } else if (_stockStatus == 'low_stock') {
        matchesStock = product.stock > 0 && product.stock <= product.minStockAlert;
      } else if (_stockStatus == 'out_of_stock') {
        matchesStock = product.stock == 0;
      }

      final matchesFeatured = !_isFeaturedOnly || product.isFeatured;

      return matchesSearch && matchesCategory && matchesPrice && matchesStock && matchesFeatured;
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
    bool? isFeaturedOnly,
  }) {
    if (categoryId != null) _selectedCategory = categoryId == 'all' ? null : categoryId;
    if (minPrice != null) _minPrice = minPrice;
    if (maxPrice != null) _maxPrice = maxPrice;
    if (stockStatus != null) _stockStatus = stockStatus;
    if (isFeaturedOnly != null) _isFeaturedOnly = isFeaturedOnly;
    _applyFilters();
  }

  /// Clears all filters.
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _stockStatus = 'all';
    _isFeaturedOnly = false;
    _applyFilters();
  }

  /// Adds a new product with multiple image uploads.
  Future<bool> addProduct(ProductModel product, List<File> imageFiles) async {
    _setLoading(true);
    try {
      List<String> imageUrls = [];
      for (var file in imageFiles) {
        String url = await _storageService.uploadImage(
          file, 
          'products/${product.shopId}/${DateTime.now().millisecondsSinceEpoch}_${imageFiles.indexOf(file)}.jpg'
        );
        imageUrls.add(url);
      }

      final newProduct = product.copyWith(
        id: const Uuid().v4(),
        images: imageUrls,
        imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _productService.addProduct(newProduct);
      await fetchShopProducts(product.shopId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing product, handling image updates.
  Future<bool> updateProduct(ProductModel product, {List<File>? newImages, List<String>? removedImages}) async {
    _setLoading(true);
    try {
      List<String> currentImages = List.from(product.images);

      // Remove deleted images from storage
      if (removedImages != null) {
        for (var url in removedImages) {
          try {
            await _storageService.deleteFile(url);
          } catch (e) {
            debugPrint('Error deleting image: $e');
          }
          currentImages.remove(url);
        }
      }

      // Upload new images
      if (newImages != null && newImages.isNotEmpty) {
        for (var file in newImages) {
          String url = await _storageService.uploadImage(
            file, 
            'products/${product.shopId}/${DateTime.now().millisecondsSinceEpoch}_new_${newImages.indexOf(file)}.jpg'
          );
          currentImages.add(url);
        }
      }

      final updatedProduct = product.copyWith(
        images: currentImages,
        imageUrl: currentImages.isNotEmpty ? currentImages[0] : '',
        updatedAt: DateTime.now(),
      );

      await _productService.updateProduct(updatedProduct);
      await fetchShopProducts(product.shopId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a product and its images.
  Future<bool> deleteProduct(ProductModel product) async {
    _setLoading(true);
    try {
      for (var url in product.images) {
        try {
          await _storageService.deleteFile(url);
        } catch (e) {
          debugPrint('Failed to delete image: $url');
        }
      }
      await _productService.deleteProduct(product.id);
      await fetchShopProducts(product.shopId);
      return true;
    } catch (e) {
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
        updatedAt: DateTime.now(),
      );
      await _productService.addProduct(duplicatedProduct);
      await fetchShopProducts(product.shopId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Archives a product by setting its status and availability.
  Future<bool> archiveProduct(ProductModel product) async {
    _setLoading(true);
    try {
      final archivedProduct = product.copyWith(
        status: 'archived',
        isAvailable: false,
        updatedAt: DateTime.now(),
      );
      await _productService.updateProduct(archivedProduct);
      await fetchShopProducts(product.shopId);
      return true;
    } catch (e) {
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
