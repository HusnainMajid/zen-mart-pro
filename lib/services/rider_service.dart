import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/rider_model.dart';
import '../models/user_model.dart';

class RiderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Fetch all riders
  Future<List<RiderModel>> getAllRiders() async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('role', isEqualTo: 'rider')
          .get();
      return snapshot.docs.map((doc) => RiderModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch riders: $e';
    }
  }

  // Create Rider (Auth + Firestore)
  Future<void> createRider({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? profileImage,
  }) async {
    FirebaseApp? secondaryApp;
    try {
      final appName = 'RiderApp_${DateTime.now().millisecondsSinceEpoch}';
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

      final user = UserModel(
        uid: uid,
        fullName: fullName,
        email: email,
        phoneNumber: phone,
        role: 'rider',
        profileImage: profileImage,
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
      throw 'Failed to create rider: $e';
    } finally {
      await secondaryApp?.delete();
    }
  }

  // Update Rider Status
  Future<void> updateRiderStatus(String uid, String status) async {
    try {
      bool isActive = status == 'active';
      await _db.collection(_collection).doc(uid).update({
        'status': status,
        'isActive': isActive,
      });
    } catch (e) {
      throw 'Failed to update rider status: $e';
    }
  }

  // Delete Rider
  Future<void> deleteRider(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw 'Failed to delete rider: $e';
    }
  }
}
