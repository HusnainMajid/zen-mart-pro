import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class AdminOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// Gets all orders across all vendors/shops for the Super Admin.
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final querySnapshot = await _db.collection(_collection).orderBy('orderTime', descending: true).get();
      return querySnapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('CRITICAL: Firestore index required. Create it here: ${e.message}');
        throw 'A required Firestore index is missing. Please check the logs or create it using the link: ${e.message}';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to get orders: $e';
    }
  }

  /// Updates order status (Admin capability).
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection(_collection).doc(orderId).update({
        'status': status,
        if (status == 'delivered') 'deliveryTime': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }
}
