import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../services/vendor_category_service.dart';

class VendorCategoryProvider with ChangeNotifier {
  final VendorCategoryService _categoryService = VendorCategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all categories for a specific shop.
  Future<void> fetchShopCategories(String shopId) async {
    _setLoading(true);
    try {
      _categories = await _categoryService.getShopCategories(shopId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new category after checking for duplicates.
  Future<bool> addCategory(CategoryModel category) async {
    _setLoading(true);
    try {
      final isDuplicate = await _categoryService.checkDuplicateCategoryName(category.name, category.shopId!);
      if (isDuplicate) {
        _errorMessage = 'Category name already exists in this shop';
        _setLoading(false);
        return false;
      }

      final newCategory = category.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
      );

      await _categoryService.addCategory(newCategory);
      await fetchShopCategories(category.shopId!);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing category.
  Future<bool> updateCategory(CategoryModel category) async {
    _setLoading(true);
    try {
      await _categoryService.updateCategory(category);
      await fetchShopCategories(category.shopId!);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a category.
  Future<bool> deleteCategory(String categoryId, String shopId) async {
    _setLoading(true);
    try {
      await _categoryService.deleteCategory(categoryId);
      await fetchShopCategories(shopId);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
