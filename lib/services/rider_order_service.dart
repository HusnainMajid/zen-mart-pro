import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class RiderOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// Stream of orders available for pickup (Ready for Pickup & No Rider assigned)
  Stream<List<OrderModel>> getAvailableOrders() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'ready_for_pickup')
        .where('riderId', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  /// Stream of active deliveries for a specific rider
  Stream<List<OrderModel>> getRiderDeliveries(String riderId) {
    return _firestore
        .collection(_collection)
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: ['accepted_by_rider', 'picked_up', 'out_for_delivery'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  /// Accept a delivery request
  Future<void> acceptDelivery(String orderId, String riderId, String riderName) async {
    return _firestore.runTransaction((transaction) async {
      DocumentReference orderRef = _firestore.collection(_collection).doc(orderId);
      DocumentSnapshot snapshot = await transaction.get(orderRef);

      if (!snapshot.exists) throw 'Order not found';

      final data = snapshot.data() as Map<String, dynamic>;
      if (data['riderId'] != null) throw 'This order has already been accepted by another rider.';
      if (data['status'] != 'ready_for_pickup') throw 'Order is no longer available for pickup.';

      transaction.update(orderRef, {
        'riderId': riderId,
        'riderName': riderName,
        'status': 'accepted_by_rider', 
      });
    });
  }

  /// Update delivery status
  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus,
        if (newStatus == 'delivered') 'deliveryTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update delivery status: $e';
    }
  }
}
