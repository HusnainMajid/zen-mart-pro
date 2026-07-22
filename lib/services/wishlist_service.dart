import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _wishlistCollection {
    if (_userId == null) throw 'User must be logged in to access wishlist.';
    return _db.collection('users').doc(_userId).collection('wishlist');
  }

  // Get wishlist items stream
  Stream<List<WishlistModel>> getWishlist() {
    try {
      return _wishlistCollection
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => WishlistModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw 'Failed to fetch wishlist: $e';
    }
  }

  // Add item to wishlist
  Future<void> addToWishlist(WishlistModel item) async {
    try {
      await _wishlistCollection.doc(item.productId).set(item.toMap());
    } catch (e) {
      throw 'Failed to add to wishlist: $e';
    }
  }

  // Remove item from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _wishlistCollection.doc(productId).delete();
    } catch (e) {
      throw 'Failed to remove from wishlist: $e';
    }
  }

  // Check if item is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      final doc = await _wishlistCollection.doc(productId).get();
      return doc.exists;
    } catch (e) {
      throw 'Failed to check wishlist status: $e';
    }
  }
}
