import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Save or update user data
  Future<void> saveUser(UserModel user) async {
    try {
      await _db.collection(_collection).doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw 'Permission Denied: Please check your Firestore Security Rules.';
      }
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to save user data: $e';
    }
  }

  // Get user data by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        try {
          return UserModel.fromMap(doc.data()!);
        } catch (e) {
          debugPrint('Error parsing UserModel: $e');
          throw 'Error parsing user profile data.';
        }
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw 'Permission Denied: Please check your Firestore Security Rules.';
      }
      if (e.code == 'not-found') return null;
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to retrieve user data: $e';
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Silent error updating last login: $e');
    }
  }

  // Check if user is Super Admin in Firestore (backup check)
  Future<bool> isSuperAdmin(String uid) async {
    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] == 'super_admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
