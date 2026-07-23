import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class CustomerOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _orderCollection => _db.collection('orders');

  // Place a new order
  Future<void> placeOrder(OrderModel order) async {
    try {
      if (_userId == null) throw 'User must be logged in to place an order.';
      
      // Ensure the customerId matches the current user
      final orderWithUser = order.copyWith(customerId: _userId);
      
      final docRef = orderWithUser.id.isEmpty 
          ? _orderCollection.doc() 
          : _orderCollection.doc(orderWithUser.id);
      
      final finalOrder = orderWithUser.id.isEmpty 
          ? orderWithUser.copyWith(id: docRef.id) 
          : orderWithUser;

      await docRef.set(finalOrder.toMap());
      
      // Optionally clear cart after placing order
      // This could be handled by a CartService instance if needed
    } catch (e) {
      throw 'Failed to place order: $e';
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      final doc = await _orderCollection.doc(orderId).get();
      if (!doc.exists) throw 'Order not found.';
      
      final order = OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      
      if (order.customerId != _userId) {
        throw 'You are not authorized to cancel this order.';
      }
      
      if (order.status != 'pending') {
        throw 'Only pending orders can be cancelled.';
      }

      await _orderCollection.doc(orderId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      throw 'Failed to cancel order: $e';
    }
  }

  // Stream order tracking
  Stream<OrderModel?> getOrderTracking(String orderId) {
    try {
      return _orderCollection.doc(orderId).snapshots().map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return null;
        return OrderModel.fromMap(snapshot.data() as Map<String, dynamic>);
      });
    } catch (e) {
      throw 'Failed to get order tracking: $e';
    }
  }

  // Get user's orders
  Stream<List<OrderModel>> getCustomerOrders() {
    try {
      if (_userId == null) throw 'User must be logged in to view orders.';
      return _orderCollection
          .where('customerId', isEqualTo: _userId)
          .orderBy('orderTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      }).handleError((e) {
        if (e is FirebaseException && e.code == 'failed-precondition') {
          debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        }
        throw e;
      });
    } catch (e) {
      throw 'Failed to fetch your orders: $e';
    }
  }
}
