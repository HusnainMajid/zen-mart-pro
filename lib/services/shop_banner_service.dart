import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_banner_model.dart';

class ShopBannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'shop_banners';

  /// Adds a new shop banner.
  Future<void> addBanner(ShopBannerModel banner) async {
    try {
      await _db.collection(_collection).doc(banner.id).set(banner.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to add shop banner: $e';
    }
  }

  /// Updates an existing shop banner.
  Future<void> updateBanner(ShopBannerModel banner) async {
    try {
      await _db.collection(_collection).doc(banner.id).update(banner.toMap());
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update shop banner: $e';
    }
  }

  /// Deletes a shop banner.
  Future<void> deleteBanner(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to delete shop banner: $e';
    }
  }

  /// Gets all shop banners.
  Future<List<ShopBannerModel>> getAllBanners() async {
    try {
      final querySnapshot = await _db.collection(_collection).orderBy('createdAt', descending: true).get();
      return querySnapshot.docs.map((doc) => ShopBannerModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to get shop banners: $e';
    }
  }
}
