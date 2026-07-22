import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _cartCollection {
    if (_userId == null) throw 'User must be logged in to access cart.';
    return _db.collection('users').doc(_userId).collection('cart');
  }

  // Get cart items stream
  Stream<List<CartItemModel>> getCartItems() {
    try {
      return _cartCollection.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => CartItemModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw 'Failed to fetch cart items: $e';
    }
  }

  // Add item to cart
  Future<void> addToCart(CartItemModel item) async {
    try {
      await _cartCollection.doc(item.productId).set(item.toMap());
    } catch (e) {
      throw 'Failed to add item to cart: $e';
    }
  }

  // Update cart item quantity
  Future<void> updateCartItem(CartItemModel item) async {
    try {
      await _cartCollection.doc(item.productId).update(item.toMap());
    } catch (e) {
      throw 'Failed to update cart item: $e';
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      await _cartCollection.doc(productId).delete();
    } catch (e) {
      throw 'Failed to remove item from cart: $e';
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      final snapshot = await _cartCollection.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to clear cart: $e';
    }
  }
}
