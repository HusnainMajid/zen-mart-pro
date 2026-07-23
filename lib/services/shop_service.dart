import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/shop_model.dart';

class ShopService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'shops';

  // Fetch all shops
  Future<List<ShopModel>> getAllShops() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs.map((doc) => ShopModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('Firestore Index Required: ${e.message}');
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch shops: $e';
    }
  }

  // Create Shop
  Future<void> createShop(ShopModel shop) async {
    try {
      // 1. Check if vendor already owns a shop
      final existingShop = await _db
          .collection(_collection)
          .where('ownerId', isEqualTo: shop.ownerId)
          .limit(1)
          .get();

      if (existingShop.docs.isNotEmpty) {
        throw 'This vendor already owns a shop.';
      }

      // 2. Create the shop doc
      // If shop.id is empty, generate one
      String shopId = shop.id.isEmpty ? _db.collection(_collection).doc().id : shop.id;
      final shopToSave = shop.copyWith(id: shopId);

      await _db.collection(_collection).doc(shopId).set(shopToSave.toMap());

      // 3. Update vendor's shopId in users collection
      await _db.collection('users').doc(shop.ownerId).update({
        'shopId': shopId,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('Firestore Index Required: ${e.message}');
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      rethrow;
    }
  }

  // Update Shop
  Future<void> updateShop(ShopModel shop) async {
    try {
      await _db.collection(_collection).doc(shop.id).update(shop.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update shop: $e';
    }
  }

  // Delete Shop
  Future<void> deleteShop(String shopId, String ownerId) async {
    try {
      await _db.collection(_collection).doc(shopId).delete();
      // Remove shopId from vendor
      await _db.collection('users').doc(ownerId).update({
        'shopId': FieldValue.delete(),
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to delete shop: $e';
    }
  }

  // Get Shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      final doc = await _db.collection(_collection).doc(shopId).get();
      if (doc.exists && doc.data() != null) {
        return ShopModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get shop details: $e';
    }
  }
}
