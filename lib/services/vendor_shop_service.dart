import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';

class VendorShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'shops';

  /// Fetches the details of a specific shop
  Future<ShopModel?> getShopDetails(String shopId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_collection).doc(shopId).get();
      
      if (doc.exists && doc.data() != null) {
        return ShopModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch shop details: ${e.toString()}';
    }
  }

  /// Updates the shop profile information
  Future<void> updateShopProfile(String shopId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(shopId).update(data);
    } catch (e) {
      throw 'Failed to update shop profile: ${e.toString()}';
    }
  }
}
