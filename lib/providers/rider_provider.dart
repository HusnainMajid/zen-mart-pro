import 'package:flutter/material.dart';
import '../models/rider_model.dart';
import '../services/rider_service.dart';

class RiderProvider with ChangeNotifier {
  final RiderService _riderService = RiderService();

  List<RiderModel> _riders = [];
  bool _isLoading = false;
  String? _error;

  List<RiderModel> get riders => _riders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRiders() async {
    _setLoading(true);
    _error = null;
    try {
      _riders = await _riderService.getAllRiders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addRider({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? profileImage,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _riderService.createRider(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        profileImage: profileImage,
      );
      await fetchRiders();
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
      await _riderService.updateRiderStatus(uid, status);
      final index = _riders.indexWhere((r) => r.uid == uid);
      if (index != -1) {
        _riders[index] = _riders[index].copyWith(status: status);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeRider(String uid) async {
    _setLoading(true);
    try {
      await _riderService.deleteRider(uid);
      _riders.removeWhere((r) => r.uid == uid);
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
