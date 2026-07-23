import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/vendor_model.dart';
import '../models/user_model.dart';

class VendorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Fetch all vendors
  Future<List<VendorModel>> getAllVendors() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('role', isEqualTo: 'vendor')
          .get();
      return snapshot.docs.map((doc) => VendorModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch vendors: $e';
    }
  }

  // Create Vendor (Auth + Firestore)
  Future<void> createVendor({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      // Use a unique name for the secondary app instance
      final appName = 'VendorApp_${DateTime.now().millisecondsSinceEpoch}';
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );

      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Create UserModel for general compatibility
      final user = UserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phone,
        role: 'vendor',
        isActive: true,
        isVerified: true,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _db.collection(_collection).doc(uid).set(user.toMap());
    } on FirebaseAuthException catch (e) {
      throw 'Auth Error [${e.code}]: ${e.message}';
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to create vendor: $e';
    } finally {
      await secondaryApp?.delete();
    }
  }

  // Update Vendor Status
  Future<void> updateVendorStatus(String uid, String status) async {
    try {
      bool isActive = status == 'active';
      await _db.collection(_collection).doc(uid).update({
        'status': status,
        'isActive': isActive,
      });
    } catch (e) {
      throw 'Failed to update vendor status: $e';
    }
  }

  // Delete Vendor
  Future<void> deleteVendor(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw 'Failed to delete vendor: $e';
    }
  }
}
