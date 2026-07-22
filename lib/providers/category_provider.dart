import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../services/storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final StorageService _storageService = StorageService();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _filteredCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetches all categories.
  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      _categories = await _categoryService.getAllCategories();
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

  /// Adds a new category with an icon image.
  Future<bool> addCategory({
    required String name,
    required String description,
    required File iconFile,
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
      final iconUrl = await _storageService.uploadImage(iconFile, 'categories/$id');

      final category = CategoryModel(
        id: id,
        name: name,
        description: description,
        iconUrl: iconUrl,
        displayOrder: 0,
        status: 'active',
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
    File? newIconFile,
  }) async {
    _setLoading(true);
    try {
      String iconUrl = category.iconUrl;
      if (newIconFile != null) {
        // Delete old icon if needed, though uploadImage usually replaces if path is same.
        // But here we use ID as path, so it's safer to just upload.
        iconUrl = await _storageService.uploadImage(newIconFile, 'categories/${category.id}');
      }

      final updatedCategory = category.copyWith(
        iconUrl: iconUrl,
      );

      await _categoryService.updateCategory(updatedCategory);
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
      await _storageService.deleteFile(category.iconUrl);
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
