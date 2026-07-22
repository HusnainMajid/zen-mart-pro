import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _notificationCollection {
    if (_userId == null) throw 'User must be logged in to access notifications.';
    return _db.collection('users').doc(_userId).collection('notifications');
  }

  // Get notifications stream
  Stream<List<NotificationModel>> getNotifications() {
    try {
      return _notificationCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw 'Failed to fetch notifications: $e';
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationCollection.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw 'Failed to update notification: $e';
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationCollection.doc(notificationId).delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final snapshot = await _notificationCollection.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to clear notifications: $e';
    }
  }
}
