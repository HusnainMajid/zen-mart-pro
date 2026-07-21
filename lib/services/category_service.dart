import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'categories';

  /// Adds a new category.
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _db.collection(_collection).doc(category.id).set(category.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to add category: $e';
    }
  }

  /// Updates an existing category.
  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _db.collection(_collection).doc(category.id).update(category.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update category: $e';
    }
  }

  /// Deletes a category.
  Future<void> deleteCategory(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to delete category: $e';
    }
  }

  /// Gets all categories.
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final querySnapshot = await _db.collection(_collection).orderBy('createdAt', descending: true).get();
      return querySnapshot.docs.map((doc) => CategoryModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to get categories: $e';
    }
  }

  /// Checks if a category with the same name already exists.
  Future<bool> checkDuplicateName(String name) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to check duplicate category name: $e';
    }
  }
}
