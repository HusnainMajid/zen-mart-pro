import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'complaints';

  /// Gets all complaints.
  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      final querySnapshot = await _db.collection(_collection).orderBy('createdAt', descending: true).get();
      return querySnapshot.docs.map((doc) => ComplaintModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to get complaints: $e';
    }
  }

  /// Updates the status of a complaint.
  Future<void> updateComplaintStatus(String id, String status) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update complaint status: $e';
    }
  }

  /// Adds a reply to a complaint and marks it as resolved or updated.
  Future<void> replyToComplaint(String id, String reply) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'reply': reply,
        'status': 'resolved', // Assuming reply usually resolves or moves the complaint forward
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to reply to complaint: $e';
    }
  }
}
