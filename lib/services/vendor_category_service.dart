import 'package:cloud_firestore/cloud_firestore.dart';
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
    } catch (e) {
      throw 'Failed to fetch shop categories: ${e.toString()}';
    }
  }

  /// Adds a new category for the vendor
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_collection).doc(category.id).set(category.toMap());
    } catch (e) {
      throw 'Failed to add category: ${e.toString()}';
    }
  }

  /// Updates an existing category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_collection).doc(category.id).update(category.toMap());
    } catch (e) {
      throw 'Failed to update category: ${e.toString()}';
    }
  }

  /// Deletes a category by its ID
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collection).doc(categoryId).delete();
    } catch (e) {
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
      throw 'Failed to check category name availability: ${e.toString()}';
    }
  }
}
