import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class VendorProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vendor_products';

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
    } catch (e) {
      throw 'Failed to fetch shop products: ${e.toString()}';
    }
  }

  /// Adds a new product to the vendor_products collection
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).set(product.toMap());
    } catch (e) {
      throw 'Failed to add product: ${e.toString()}';
    }
  }

  /// Updates an existing product's details
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update(product.toMap());
    } catch (e) {
      throw 'Failed to update product: ${e.toString()}';
    }
  }

  /// Deletes a product by its ID
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
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
    } catch (e) {
      throw 'Failed to check SKU availability: ${e.toString()}';
    }
  }
}
