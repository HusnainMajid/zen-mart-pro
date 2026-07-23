import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class VendorCategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vendor_categories';

  /// Fetches all categories for a specific shop
  Future<List<CategoryModel>> getShopCategories(String shopId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .orderBy('displayOrder', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch shop categories: ${e.toString()}';
    }
  }

  /// Fetches all categories across all shops
  Future<List<CategoryModel>> getAllVendorCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all categories: $e');
      throw 'Failed to fetch categories: ${e.toString()}';
    }
  }

  /// Adds a new category for the vendor
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_collection).doc(category.id).set(category.toMap());
    } catch (e) {
      debugPrint('Error adding category: $e');
      throw 'Failed to add category: ${e.toString()}';
    }
  }

  /// Updates an existing category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_collection).doc(category.id).update(category.toMap());
    } catch (e) {
      debugPrint('Error updating category: $e');
      throw 'Failed to update category: ${e.toString()}';
    }
  }

  /// Deletes a category by its ID
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collection).doc(categoryId).delete();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      throw 'Failed to delete category: ${e.toString()}';
    }
  }

  /// Checks if a category name already exists for a specific shop
  Future<bool> checkDuplicateCategoryName(String name, String shopId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking duplicate category: $e');
      throw 'Failed to check category name availability: ${e.toString()}';
    }
  }
}
