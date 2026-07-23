import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Fetch all customers (role='customer')
  Future<List<UserModel>> getAllCustomers() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('role', isEqualTo: 'customer')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint('Firestore Index Required: ${e.message}');
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch customers: $e';
    }
  }

  // Toggle isActive status
  Future<void> toggleCustomerStatus(String uid, bool isActive) async {
    try {
      await _db.collection(_collection).doc(uid).update({
        'isActive': isActive,
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update customer status: $e';
    }
  }

  // Update customer profile
  Future<void> updateProfile(UserModel user) async {
    try {
      await _db.collection(_collection).doc(user.uid).update({
        'fullName': user.fullName,
        'phoneNumber': user.phoneNumber,
      });
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }
}
