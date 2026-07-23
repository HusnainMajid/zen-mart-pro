import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class AdminProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Gets all products across all shops for the Super Admin.
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await _db.collection(_collection).orderBy('createdAt', descending: true).get();
      return querySnapshot.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to get products: $e';
    }
  }

  /// Deletes a product (Admin capability).
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection(_collection).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }
}
