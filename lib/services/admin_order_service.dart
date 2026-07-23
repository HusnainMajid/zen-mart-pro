import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class AdminOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// Gets all orders stream across all vendors/shops for the Super Admin.
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _db
        .collection(_collection)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  /// Gets all orders once.
  Future<List<OrderModel>> getAllOrdersOnce() async {
    final snapshot = await _db
        .collection(_collection)
        .orderBy('orderTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
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
