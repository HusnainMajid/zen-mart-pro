import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

/// Service to handle vendor-specific order operations
class VendorOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// Stream of all orders for a specific shop
  Stream<List<OrderModel>> getShopOrdersStream(String shopId) {
    return _firestore
        .collection(_collection)
        .where('shopId', isEqualTo: shopId)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  /// Gets all orders for a shop once.
  Future<List<OrderModel>> getShopOrdersOnce(String shopId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('shopId', isEqualTo: shopId)
        .orderBy('orderTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
  }

  /// Update order status with validation
  /// Allowed transitions: Pending -> Accepted -> Preparing -> Ready For Pickup
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) throw 'Order not found';

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final String currentStatus = data['status']?.toString().toLowerCase() ?? 'pending';
      final String targetStatus = newStatus.toLowerCase();

      if (!_isValidTransition(currentStatus, targetStatus)) {
        throw 'Invalid status transition from $currentStatus to $newStatus';
      }

      await _firestore.collection(_collection).doc(orderId).update({
        'status': targetStatus,
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update order status: ${e.toString()}';
    }
  }

  /// Validates status transitions based on vendor workflow
  bool _isValidTransition(String current, String next) {
    const Map<String, List<String>> allowedTransitions = {
      'pending': ['accepted', 'cancelled'],
      'accepted': ['preparing', 'cancelled'],
      'preparing': ['ready_for_pickup', 'cancelled'],
      'ready_for_pickup': ['shipped', 'delivered', 'cancelled'],
    };

    return allowedTransitions[current]?.contains(next) ?? false;
  }

  /// Helper to change status to 'accepted'
  Future<void> acceptOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, 'accepted');
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to accept order: ${e.toString()}';
    }
  }

  /// Helper to change status to 'cancelled' (rejected)
  Future<void> rejectOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, 'cancelled');
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to reject order: ${e.toString()}';
    }
  }
}
