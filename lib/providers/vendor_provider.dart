import 'package:flutter/material.dart';
import '../models/vendor_model.dart';
import '../services/vendor_service.dart';

class VendorProvider with ChangeNotifier {
  final VendorService _vendorService = VendorService();

  List<VendorModel> _vendors = [];
  bool _isLoading = false;
  String? _error;

  List<VendorModel> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVendors() async {
    _setLoading(true);
    _error = null;
    try {
      _vendors = await _vendorService.getAllVendors();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addVendor({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _vendorService.createVendor(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      await fetchVendors(); // Refresh list
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStatus(String uid, String status) async {
    _setLoading(true);
    _error = null;
    try {
      await _vendorService.updateVendorStatus(uid, status);
      // Optimistic update or refresh
      final index = _vendors.indexWhere((v) => v.uid == uid);
      if (index != -1) {
        _vendors[index] = _vendors[index].copyWith(status: status);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeVendor(String uid) async {
    _setLoading(true);
    try {
      await _vendorService.deleteVendor(uid);
      _vendors.removeWhere((v) => v.uid == uid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
