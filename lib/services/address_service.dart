import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _addressCollection {
    return _db.collection('customer_addresses');
  }

  // Get addresses stream filtered by userId
  Stream<List<AddressModel>> getAddresses() {
    try {
      if (_userId == null) return Stream.value([]);
      
      return _addressCollection
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => AddressModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw 'Failed to fetch addresses: $e';
    }
  }

  // Add new address
  Future<void> addAddress(AddressModel address) async {
    try {
      if (_userId == null) throw 'User must be logged in to add address.';
      
      final docRef = _addressCollection.doc();
      final newAddress = address.copyWith(
        id: docRef.id,
        userId: _userId,
      );
      
      if (newAddress.isDefault) {
        await _clearDefaultAddress();
      }
      
      await docRef.set(newAddress.toMap());
    } catch (e) {
      throw 'Failed to add address: $e';
    }
  }

  // Update address
  Future<void> updateAddress(AddressModel address) async {
    try {
      if (address.isDefault) {
        await _clearDefaultAddress();
      }
      await _addressCollection.doc(address.id).update(address.toMap());
    } catch (e) {
      throw 'Failed to update address: $e';
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressCollection.doc(addressId).delete();
    } catch (e) {
      throw 'Failed to delete address: $e';
    }
  }

  // Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      await _clearDefaultAddress();
      await _addressCollection.doc(addressId).update({'isDefault': true});
    } catch (e) {
      throw 'Failed to set default address: $e';
    }
  }

  // Helper to clear existing default address for current user only
  Future<void> _clearDefaultAddress() async {
    if (_userId == null) return;
    
    final query = await _addressCollection
        .where('userId', isEqualTo: _userId)
        .where('isDefault', isEqualTo: true)
        .get();
        
    final batch = _db.batch();
    for (var doc in query.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
