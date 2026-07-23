import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class VendorProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Fetches all products for a specific shop
  Future<List<ProductModel>> getShopProducts(String shopId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch shop products: ${e.toString()}';
    }
  }

  /// Adds a new product to the vendor_products collection
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).set(product.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to add product: ${e.toString()}';
    }
  }

  /// Updates an existing product's details
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update(product.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update product: ${e.toString()}';
    }
  }

  /// Deletes a product by its ID
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to delete product: ${e.toString()}';
    }
  }

  /// Checks if a SKU already exists for a specific shop
  Future<bool> checkDuplicateSKU(String sku, String shopId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('shopId', isEqualTo: shopId)
          .where('sku', isEqualTo: sku)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to check SKU availability: ${e.toString()}';
    }
  }
}
