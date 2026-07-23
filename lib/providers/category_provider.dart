import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/vendor_category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final VendorCategoryService _vendorCategoryService = VendorCategoryService();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _filteredCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all categories (Global + Vendor).
  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final globalCategories = await _categoryService.getAllCategories();
      final vendorCategories = await _vendorCategoryService.getAllVendorCategories();
      
      // Combine and remove duplicates by name
      final Map<String, CategoryModel> combined = {};
      for (var cat in globalCategories) {
        combined[cat.name.toLowerCase()] = cat;
      }
      for (var cat in vendorCategories) {
        combined[cat.name.toLowerCase()] = cat;
      }
      
      _categories = combined.values.toList();
      _categories.sort((a, b) => a.name.compareTo(b.name));
      
      _filteredCategories = List.from(_categories);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Searches categories by name.
  void searchCategories(String query) {
    if (query.isEmpty) {
      _filteredCategories = List.from(_categories);
    } else {
      _filteredCategories = _categories
          .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Adds a new category.
  Future<bool> addCategory({
    required String name,
    required String description,
  }) async {
    _setLoading(true);
    try {
      final isDuplicate = await _categoryService.checkDuplicateName(name);
      if (isDuplicate) {
        _errorMessage = 'Category name already exists.';
        _setLoading(false);
        return false;
      }

      final id = const Uuid().v4();

      final category = CategoryModel(
        id: id,
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      await _categoryService.addCategory(category);
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing category.
  Future<bool> updateCategory({
    required CategoryModel category,
  }) async {
    _setLoading(true);
    try {
      await _categoryService.updateCategory(category);
      await fetchCategories();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a category.
  Future<bool> deleteCategory(CategoryModel category) async {
    _setLoading(true);
    try {
      await _categoryService.deleteCategory(category.id);
      await fetchCategories();
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
